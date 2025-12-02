using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuanLyLinhKienPC
{
    public partial class QuanLyDanhMuc : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
            {
                Response.Redirect("Login.aspx");
            }

            this.Form.Target = "_self";

            if (!IsPostBack)
            {
                LoadDanhSach();     // Load toàn bộ ban đầu
                LoadDropdownCha();  // Load dropdown trong Form nhập liệu
                LoadFilter();       // Load dropdown Bộ lọc trên Toolbar
            }
        }

        // --- 1. HÀM LOAD DANH SÁCH (CÓ TÌM KIẾM & LỌC) ---
        void LoadDanhSach(string keyword = "", string parentID = "All")
        {
            string sql = @"SELECT A.MaDanhMuc, A.TenDanhMuc, B.TenDanhMuc AS TenCha 
                           FROM DanhMuc A 
                           LEFT JOIN DanhMuc B ON A.MaDanhMucCha = B.MaDanhMuc
                           WHERE 1=1 "; // Mẹo để nối chuỗi điều kiện dễ hơn

            List<SqlParameter> paraList = new List<SqlParameter>();

            // Logic Tìm kiếm
            if (!string.IsNullOrEmpty(keyword))
            {
                sql += " AND A.TenDanhMuc LIKE @Keyword ";
                paraList.Add(new SqlParameter("@Keyword", "%" + keyword + "%"));
            }

            // Logic Bộ lọc
            if (parentID != "All")
            {
                if (parentID == "Root") // Lọc danh mục gốc
                {
                    sql += " AND A.MaDanhMucCha IS NULL ";
                }
                else // Lọc theo cha cụ thể
                {
                    sql += " AND A.MaDanhMucCha = @ParentID ";
                    paraList.Add(new SqlParameter("@ParentID", parentID));
                }
            }

            sql += " ORDER BY A.MaDanhMuc DESC";

            gvDanhMuc.DataSource = db.GetData(sql, paraList.ToArray());
            gvDanhMuc.DataBind();
        }

        // Load Dropdown trong Form nhập liệu (chỉ lấy danh mục gốc)
        void LoadDropdownCha()
        {
            string sql = "SELECT * FROM DanhMuc WHERE MaDanhMucCha IS NULL";
            DataTable dt = db.GetData(sql);

            ddlCha.DataSource = dt;
            ddlCha.DataTextField = "TenDanhMuc";
            ddlCha.DataValueField = "MaDanhMuc";
            ddlCha.DataBind();
            ddlCha.Items.Insert(0, new ListItem("-- Là Danh Mục Gốc --", "0"));
        }

        // Load Dropdown Bộ lọc (trên Toolbar)
        void LoadFilter()
        {
            string sql = "SELECT * FROM DanhMuc WHERE MaDanhMucCha IS NULL";
            DataTable dt = db.GetData(sql);

            ddlFilter.DataSource = dt;
            ddlFilter.DataTextField = "TenDanhMuc";
            ddlFilter.DataValueField = "MaDanhMuc";
            ddlFilter.DataBind();

            // Thêm các tùy chọn đặc biệt
            ddlFilter.Items.Insert(0, new ListItem("-- Lọc: Danh Mục Gốc --", "Root"));
            ddlFilter.Items.Insert(0, new ListItem("-- Tất cả --", "All"));
        }

        // --- 2. SỰ KIỆN TÌM KIẾM & LỌC ---
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            // Gọi hàm Load với từ khóa tìm kiếm và giá trị lọc hiện tại
            LoadDanhSach(txtTimKiem.Text.Trim(), ddlFilter.SelectedValue);
        }

        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Khi chọn lọc, cũng giữ nguyên từ khóa tìm kiếm (nếu có)
            LoadDanhSach(txtTimKiem.Text.Trim(), ddlFilter.SelectedValue);
        }

        // --- 3. CÁC CHỨC NĂNG CRUD (GIỮ NGUYÊN) ---
        protected void btnLuu_Click(object sender, EventArgs e)
        {
            if (txtTen.Text.Trim() == "") { ShowMsg("Nhập tên danh mục!", false); return; }

            object maCha = DBNull.Value;
            if (ddlCha.SelectedValue != "0")
            {
                if (hdfID.Value == ddlCha.SelectedValue) { ShowMsg("Không thể chọn chính mình làm cha!", false); return; }
                maCha = ddlCha.SelectedValue;
            }

            SqlParameter[] p = { new SqlParameter("@Ten", txtTen.Text.Trim()), new SqlParameter("@Cha", maCha) };

            if (hdfID.Value == "")
            {
                if (db.ExecuteQuery("INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES (@Ten, @Cha)", p))
                {
                    ShowMsg("Thêm thành công!", true); ResetForm();
                }
            }
            else
            {
                Array.Resize(ref p, p.Length + 1);
                p[p.Length - 1] = new SqlParameter("@ID", hdfID.Value);
                if (db.ExecuteQuery("UPDATE DanhMuc SET TenDanhMuc=@Ten, MaDanhMucCha=@Cha WHERE MaDanhMuc=@ID", p))
                {
                    ShowMsg("Cập nhật xong!", true); ResetForm();
                }
            }
        }

        protected void gvDanhMuc_SelectedIndexChanged(object sender, EventArgs e)
        {
            string id = gvDanhMuc.DataKeys[gvDanhMuc.SelectedRow.RowIndex].Value.ToString();
            DataTable dt = db.GetData("SELECT * FROM DanhMuc WHERE MaDanhMuc = " + id);
            if (dt.Rows.Count > 0)
            {
                txtTen.Text = dt.Rows[0]["TenDanhMuc"].ToString();
                ddlCha.SelectedValue = dt.Rows[0]["MaDanhMucCha"] != DBNull.Value ? dt.Rows[0]["MaDanhMucCha"].ToString() : "0";
                hdfID.Value = id;
                btnLuu.Text = "Cập Nhật"; btnLuu.CssClass = "btn btn-warning";
                lblTieuDe.Text = "Sửa Danh Mục"; btnHuy.Visible = true;
            }
        }

        protected void gvDanhMuc_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string id = gvDanhMuc.DataKeys[e.RowIndex].Value.ToString();

            // Check ràng buộc trước khi xóa
            if ((int)db.ExecuteScalar($"SELECT COUNT(*) FROM SanPham WHERE MaDanhMuc = {id}") > 0)
            {
                ShowMsg("Lỗi: Danh mục này đang có sản phẩm!", false); return;
            }
            if ((int)db.ExecuteScalar($"SELECT COUNT(*) FROM DanhMuc WHERE MaDanhMucCha = {id}") > 0)
            {
                ShowMsg("Lỗi: Danh mục này đang có danh mục con!", false); return;
            }

            db.ExecuteQuery($"DELETE FROM DanhMuc WHERE MaDanhMuc = {id}");
            ShowMsg("Đã xóa!", true);
            if (hdfID.Value == id) ResetForm(); else LoadDanhSach(txtTimKiem.Text, ddlFilter.SelectedValue);
        }

        protected void btnHuy_Click(object sender, EventArgs e) { ResetForm(); }

        void ResetForm()
        {
            txtTen.Text = ""; ddlCha.SelectedIndex = 0; hdfID.Value = "";
            btnLuu.Text = "Thêm Mới"; btnLuu.CssClass = "btn btn-success";
            lblTieuDe.Text = "Tạo Mới"; btnHuy.Visible = false;

            LoadDanhSach(txtTimKiem.Text, ddlFilter.SelectedValue);
            LoadDropdownCha(); // Refresh lại dropdown cha phòng khi vừa thêm/xóa danh mục gốc
            LoadFilter();      // Refresh lại bộ lọc
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-2 text-center fw-bold text-success" : "d-block mt-2 text-center fw-bold text-danger";
        }

        // --- 4. IMPORT / EXPORT ---

        // Export XML
        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            DataTable dt = db.GetData("SELECT * FROM DanhMuc ORDER BY MaDanhMuc ASC");
            dt.TableName = "DanhMuc";
            using (StringWriter sw = new StringWriter())
            {
                dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                DownloadContent(sw.ToString(), "text/xml", "DanhMuc_Backup.xml");
            }
        }

        // Export MySQL Script
        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            DataTable dt = db.GetData("SELECT * FROM DanhMuc ORDER BY MaDanhMuc ASC");
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("INSERT INTO `DanhMuc` (`MaDanhMuc`, `TenDanhMuc`, `MaDanhMucCha`) VALUES");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                string id = r["MaDanhMuc"].ToString();
                string ten = r["TenDanhMuc"].ToString().Replace("'", "''");
                string cha = r["MaDanhMucCha"] != DBNull.Value ? r["MaDanhMucCha"].ToString() : "NULL";

                sb.Append($"({id}, '{ten}', {cha})");
                sb.AppendLine(i < dt.Rows.Count - 1 ? "," : ";");
            }
            DownloadContent(sb.ToString(), "text/plain", "DanhMuc_MySQL.sql");
        }

        // Import Handler
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
                        DataSet ds = new DataSet(); ds.ReadXml(stream);
                        foreach (DataRow r in ds.Tables[0].Rows)
                        {
                            string ten = r["TenDanhMuc"].ToString();
                            object cha = r["MaDanhMucCha"].ToString() != "" ? r["MaDanhMucCha"] : DBNull.Value;

                            SqlCommand cmd = new SqlCommand("INSERT INTO DanhMuc (TenDanhMuc, MaDanhMucCha) VALUES (@t, @c)", conn);
                            cmd.Parameters.AddWithValue("@t", ten);
                            cmd.Parameters.AddWithValue("@c", cha);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else // SQL
                    {
                        using (StreamReader sr = new StreamReader(stream))
                        {
                            string sql = sr.ReadToEnd().Replace("`", ""); // Clean MySQL format
                            foreach (string cmdText in sql.Split(';'))
                            {
                                if (string.IsNullOrWhiteSpace(cmdText)) continue;
                                try { new SqlCommand(cmdText, conn).ExecuteNonQuery(); } catch { }
                            }
                        }
                    }
                }
                ResetForm();
                ShowMsg("Import thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        // Hàm download file (đã fix lỗi dính HTML)
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