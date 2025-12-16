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
    public class Utf8StringWriter : StringWriter { public override Encoding Encoding => Encoding.UTF8; }

    public partial class QuanLyKhachHang : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
            {
                Response.Redirect("Login.aspx");
            }

            this.Form.Target = "_self";

            ScriptManager sm = ScriptManager.GetCurrent(this);
            if (sm != null)
            {
                sm.RegisterPostBackControl(btnExportXML);
                sm.RegisterPostBackControl(btnExportSQL);
                sm.RegisterPostBackControl(btnExportMySQL);
            }

            if (!IsPostBack)
            {
                LoadFilterRole();
                LoadKhachHang();
                InitDropdowns();
            }
        }

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
            DataTable dt = db.GetData("SELECT * FROM VaiTro");
            ddlFilterRole.DataSource = dt;
            ddlFilterRole.DataTextField = "TenVaiTro";
            ddlFilterRole.DataValueField = "MaVaiTro";
            ddlFilterRole.DataBind();
            ddlFilterRole.Items.Insert(0, new ListItem("-- Tất cả Vai Trò --", "All"));
        }

        void InitDropdowns()
        {
            DataTable dt = db.GetData("SELECT * FROM VaiTro");
            ddlNewRole.DataSource = dt;
            ddlNewRole.DataTextField = "TenVaiTro";
            ddlNewRole.DataValueField = "MaVaiTro";
            ddlNewRole.DataBind();
            if (ddlNewRole.Items.FindByValue("2") != null) ddlNewRole.SelectedValue = "2";
        }

        protected void btnTimKiem_Click(object sender, EventArgs e) { LoadKhachHang(txtTimKiem.Text.Trim(), ddlFilterRole.SelectedValue); }
        protected void ddlFilterRole_SelectedIndexChanged(object sender, EventArgs e) { LoadKhachHang(txtTimKiem.Text.Trim(), ddlFilterRole.SelectedValue); }

        protected void gvKhachHang_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "XemChiTiet")
            {
                Response.Redirect("CapNhatTaiKhoan.aspx?id=" + e.CommandArgument.ToString());
            }
        }

        protected void btnSaveAccount_Click(object sender, EventArgs e)
        {
            if (txtNewUser.Text == "" || txtNewPass.Text == "" || txtNewName.Text == "")
            {
                ShowMsg("Vui lòng nhập đủ thông tin (*)", false);
                return;
            }
            try
            {
                string sql = @"INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, SoDienThoai, DiaChi, MaVaiTro, TrangThai, NgayTao)
                               VALUES (@u, @p, @n, @e, @ph, @a, @r, 1, GETDATE())";
                SqlParameter[] p = {
                    new SqlParameter("@u", txtNewUser.Text.Trim()),
                    new SqlParameter("@p", txtNewPass.Text.Trim()),
                    new SqlParameter("@n", txtNewName.Text.Trim()),
                    new SqlParameter("@e", txtNewEmail.Text.Trim()),
                    new SqlParameter("@ph", txtNewPhone.Text.Trim()),
                    new SqlParameter("@a", txtNewAddress.Text.Trim()),
                    new SqlParameter("@r", ddlNewRole.SelectedValue)
                };
                db.ExecuteQuery(sql, p);
                txtNewUser.Text = ""; txtNewPass.Text = "";
                LoadKhachHang();
                ShowMsg("Thêm tài khoản thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM NguoiDung");
                dt.TableName = "NguoiDung";
                using (StringWriter sw = new StringWriter())
                {
                    dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                    DownloadContent(sw.ToString(), "text/xml", "NguoiDung_Backup.xml");
                }
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportSQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM NguoiDung");
                string sql = GenerateInsertScript(dt, "SQLServer", "[NguoiDung]");
                DownloadContent(sql, "text/plain", "NguoiDung_SQLServer.sql");
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM NguoiDung");
                string sql = GenerateInsertScript(dt, "MySQL", "`NguoiDung`");
                DownloadContent(sql, "text/plain", "NguoiDung_MySQL.sql");
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        private string GenerateInsertScript(DataTable dt, string dbType, string tableName)
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine($"-- DATA BACKUP ({dbType})");
            sb.AppendLine($"-- DATE: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            sb.AppendLine("");

            if (dbType == "SQLServer")
            {
                sb.AppendLine($"SET IDENTITY_INSERT {tableName} ON;");
                sb.AppendLine("GO");
            }

            foreach (DataRow row in dt.Rows)
            {
                string values = "";
                foreach (DataColumn col in dt.Columns)
                {
                    if (values != "") values += ", ";
                    object val = row[col];

                    if (val == DBNull.Value || val.ToString() == "") values += "NULL";
                    else if (IsNumber(val)) values += val.ToString().Replace(",", "."); 
                    else if (val is bool) values += ((bool)val) ? "1" : "0";         
                    else if (val is DateTime) values += $"'{((DateTime)val):yyyy-MM-dd HH:mm:ss}'"; 
                    {
                        string strVal = val.ToString().Replace("'", "''");
                        if (dbType == "SQLServer") values += $"N'{strVal}'";
                        else values += $"'{strVal}'";
                    }
                }
                sb.AppendLine($"INSERT INTO {tableName} VALUES ({values});");
            }

            if (dbType == "SQLServer")
            {
                sb.AppendLine("GO");
                sb.AppendLine($"SET IDENTITY_INSERT {tableName} OFF;");
            }

            return sb.ToString();
        }

        private bool IsNumber(object value)
        {
            return value is sbyte || value is byte || value is short || value is ushort ||
                   value is int || value is uint || value is long || value is ulong ||
                   value is float || value is double || value is decimal;
        }

        void DownloadContent(string content, string contentType, string fileName)
        {
            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();

            Response.Buffer = true;
            Response.Charset = "";
            Response.ContentEncoding = System.Text.Encoding.UTF8;

            Response.BinaryWrite(System.Text.Encoding.UTF8.GetPreamble());

            Response.ContentType = contentType;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);

            Response.Write(content);
            Response.Flush();

            Response.SuppressContent = true;
            HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-3 text-center fw-bold text-success" : "d-block mt-3 text-center fw-bold text-danger";
        }

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
                    if (type == "XML") ProcessImportXML(stream, conn);
                    else
                    {
                        using (StreamReader sr = new StreamReader(stream))
                        {
                            string sql = sr.ReadToEnd().Replace("`", "");
                            foreach (string cmdText in sql.Split(';'))
                                if (!string.IsNullOrWhiteSpace(cmdText)) try { new SqlCommand(cmdText, conn).ExecuteNonQuery(); } catch { }
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
                try
                {
                    string sql = @"INSERT INTO NguoiDung (TenDangNhap, MatKhauHash, HoTen, Email, SoDienThoai, DiaChi, MaVaiTro, TrangThai) 
                                   VALUES (@user, @pass, @name, @email, @phone, @addr, @role, 1)";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@user", r["TenDangNhap"]);
                    cmd.Parameters.AddWithValue("@pass", "123456");
                    cmd.Parameters.AddWithValue("@name", r["HoTen"]);
                    cmd.Parameters.AddWithValue("@email", r["Email"]);
                    cmd.Parameters.AddWithValue("@phone", r.Table.Columns.Contains("SoDienThoai") ? r["SoDienThoai"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@addr", r.Table.Columns.Contains("DiaChi") ? r["DiaChi"] : DBNull.Value);
                    cmd.Parameters.AddWithValue("@role", r["MaVaiTro"]);
                    cmd.ExecuteNonQuery();
                }
                catch { }
            }
        }
    }
}