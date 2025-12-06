using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

namespace QuanLyLinhKienPC
{
    public partial class QuanLyKhachHang : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Kiểm tra quyền Admin (thống nhất Role = 1)
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
            {
                Response.Redirect("Login.aspx");
            }

            this.Form.Target = "_self";

            if (!IsPostBack)
            {
                LoadFilterRole();
                LoadKhachHang();
            }
        }

        // --- 1. LOAD DANH SÁCH (TÌM KIẾM & LỌC) ---
        void LoadKhachHang(string keyword = "", string roleID = "All")
        {
            string sql = @"SELECT nd.MaNguoiDung, nd.TenDangNhap, nd.HoTen, nd.Email, nd.SoDienThoai, nd.DiaChi, vt.TenVaiTro 
                           FROM NguoiDung nd 
                           JOIN VaiTro vt ON nd.MaVaiTro = vt.MaVaiTro 
                           WHERE 1=1 ";

            List<SqlParameter> paraList = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(keyword))
            {
                sql += " AND (nd.HoTen LIKE @Key OR nd.TenDangNhap LIKE @Key) ";
                paraList.Add(new SqlParameter("@Key", "%" + keyword + "%"));
            }

            if (roleID != "All")
            {
                sql += " AND nd.MaVaiTro = @Role ";
                paraList.Add(new SqlParameter("@Role", roleID));
            }

            sql += " ORDER BY nd.MaNguoiDung DESC";

            gvKhachHang.DataSource = db.GetData(sql, paraList.ToArray());
            gvKhachHang.DataBind();
        }

        void LoadFilterRole()
        {
            // Lấy danh sách Vai trò để đổ vào Dropdown lọc
            DataTable dt = db.GetData("SELECT * FROM VaiTro");
            ddlFilterRole.DataSource = dt;
            ddlFilterRole.DataTextField = "TenVaiTro";
            ddlFilterRole.DataValueField = "MaVaiTro";
            ddlFilterRole.DataBind();

            ddlFilterRole.Items.Insert(0, new ListItem("-- Tất cả Vai Trò --", "All"));
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadKhachHang(txtTimKiem.Text.Trim(), ddlFilterRole.SelectedValue);
        }

        protected void ddlFilterRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadKhachHang(txtTimKiem.Text.Trim(), ddlFilterRole.SelectedValue);
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-3 text-center fw-bold text-success" : "d-block mt-3 text-center fw-bold text-danger";
        }

        // --- 2. EXPORT ---

        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            // Export bảng NguoiDung (loại bỏ cột mật khẩu nếu cần bảo mật, ở đây giữ nguyên để backup)
            DataTable dt = db.GetData("SELECT * FROM NguoiDung");
            dt.TableName = "NguoiDung";
            using (StringWriter sw = new StringWriter())
            {
                dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                DownloadContent(sw.ToString(), "text/xml", "NguoiDung_Backup.xml");
            }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            DataTable dt = db.GetData("SELECT * FROM NguoiDung");
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("INSERT INTO `NguoiDung` (`MaNguoiDung`, `TenDangNhap`, `MatKhauHash`, `HoTen`, `Email`, `SoDienThoai`, `DiaChi`, `MaVaiTro`, `TrangThai`) VALUES");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                // Xử lý các giá trị string
                string tenDN = r["TenDangNhap"].ToString();
                string pass = r["MatKhauHash"].ToString(); // Mật khẩu hash
                string hoTen = r["HoTen"].ToString().Replace("'", "''");
                string email = r["Email"].ToString();
                string sdt = r["SoDienThoai"] != DBNull.Value ? $"'{r["SoDienThoai"]}'" : "NULL";
                string dc = r["DiaChi"] != DBNull.Value ? $"N'{r["DiaChi"].ToString().Replace("'", "''")}'" : "NULL";
                string role = r["MaVaiTro"].ToString();
                string status = Convert.ToBoolean(r["TrangThai"]) ? "1" : "0";

                sb.Append($"({r["MaNguoiDung"]}, '{tenDN}', '{pass}', N'{hoTen}', '{email}', {sdt}, {dc}, {role}, {status})");
                sb.AppendLine(i < dt.Rows.Count - 1 ? "," : ";");
            }
            // MySQL bỏ chữ N trước chuỗi
            DownloadContent(sb.ToString().Replace("N'", "'"), "text/plain", "NguoiDung_MySQL.sql");
        }

        // --- 3. IMPORT ---

        protected void btnImportData_Click(object sender, EventArgs e)
        {
            if (!fileUploadImport.HasFile) { ShowMsg("Vui lòng chọn file!", false); return; }

            try
            {
                string type = ddlImportType.SelectedValue;
                Stream stream = fileUploadImport.PostedFile.InputStream;

                using (SqlConnection conn = new SqlConnection(db.ConnectionString))
                {
                    conn.Open();
                    if (type == "XML")
                    {
                        ProcessImportXML(stream, conn);
                    }
                    else // SQL
                    {
                        using (StreamReader sr = new StreamReader(stream))
                        {
                            string sql = sr.ReadToEnd().Replace("`", "");
                            foreach (string cmdText in sql.Split(';'))
                            {
                                if (!string.IsNullOrWhiteSpace(cmdText))
                                    try { new SqlCommand(cmdText, conn).ExecuteNonQuery(); } catch { }
                            }
                        }
                    }
                }
                LoadKhachHang();
                ShowMsg("Import thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        private void ProcessImportXML(Stream stream, SqlConnection conn)
        {
            DataSet ds = new DataSet(); ds.ReadXml(stream);
            foreach (DataRow r in ds.Tables[0].Rows)
            {
                // Kiểm tra xem user đã tồn tại chưa (qua TenDangNhap hoặc Email)
                string check = $"SELECT COUNT(*) FROM NguoiDung WHERE TenDangNhap = '{r["TenDangNhap"]}' OR Email = '{r["Email"]}'";
                SqlCommand cmdCheck = new SqlCommand(check, conn);
                if ((int)cmdCheck.ExecuteScalar() > 0) continue; // Bỏ qua nếu trùng

                string sql = @"INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, SoDienThoai, DiaChi, MaVaiTro, TrangThai) 
                               VALUES (@user, @pass, @name, @email, @phone, @addr, @role, 1)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@user", r["TenDangNhap"]);

                // Nếu XML không có pass (vd tạo mới), set mặc định là "123456"
                string pass = r.Table.Columns.Contains("MatKhauHash") ? r["MatKhauHash"].ToString() : "123456";
                cmd.Parameters.AddWithValue("@pass", pass);

                cmd.Parameters.AddWithValue("@name", r["HoTen"]);
                cmd.Parameters.AddWithValue("@email", r["Email"]);
                cmd.Parameters.AddWithValue("@phone", r.Table.Columns.Contains("SoDienThoai") ? r["SoDienThoai"] : DBNull.Value);
                cmd.Parameters.AddWithValue("@addr", r.Table.Columns.Contains("DiaChi") ? r["DiaChi"] : DBNull.Value);
                cmd.Parameters.AddWithValue("@role", r["MaVaiTro"]); // Cần đảm bảo RoleID này tồn tại

                cmd.ExecuteNonQuery();
            }
        }

        void DownloadContent(string content, string type, string name)
        {
            Response.Clear();
            Response.ClearHeaders();
            Response.Buffer = true;
            Response.Charset = "utf-8";
            Response.ContentEncoding = Encoding.UTF8;
            Response.BinaryWrite(Encoding.UTF8.GetPreamble());
            Response.ContentType = type;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + name);
            Response.Write(content);
            Response.Flush();
            Response.End();
        }
    }
}