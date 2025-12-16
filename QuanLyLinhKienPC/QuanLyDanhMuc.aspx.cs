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

            ScriptManager sm = ScriptManager.GetCurrent(this);
            if (sm != null)
            {
                sm.RegisterPostBackControl(btnExportXML);
                sm.RegisterPostBackControl(btnExportSQL);
                sm.RegisterPostBackControl(btnExportMySQL);
            }

            if (!IsPostBack)
            {
                LoadDanhSach();
                LoadDropdownCha();
                LoadFilter();
            }
        }

        void LoadDanhSach(string keyword = "", string parentID = "All")
        {
            string sql = @"SELECT A.MaDanhMuc, A.TenDanhMuc, B.TenDanhMuc AS TenCha 
                           FROM DanhMuc A 
                           LEFT JOIN DanhMuc B ON A.MaDanhMucCha = B.MaDanhMuc
                           WHERE 1=1 ";
            List<SqlParameter> paraList = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(keyword))
            {
                sql += " AND A.TenDanhMuc LIKE @Keyword ";
                paraList.Add(new SqlParameter("@Keyword", "%" + keyword + "%"));
            }

            if (parentID != "All")
            {
                if (parentID == "Root") sql += " AND A.MaDanhMucCha IS NULL ";
                else
                {
                    sql += " AND A.MaDanhMucCha = @ParentID ";
                    paraList.Add(new SqlParameter("@ParentID", parentID));
                }
            }
            sql += " ORDER BY A.MaDanhMuc DESC";

            gvDanhMuc.DataSource = db.GetData(sql, paraList.ToArray());
            gvDanhMuc.DataBind();
        }

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

        void LoadFilter()
        {
            string sql = "SELECT * FROM DanhMuc WHERE MaDanhMucCha IS NULL";
            DataTable dt = db.GetData(sql);
            ddlFilter.DataSource = dt;
            ddlFilter.DataTextField = "TenDanhMuc";
            ddlFilter.DataValueField = "MaDanhMuc";
            ddlFilter.DataBind();
            ddlFilter.Items.Insert(0, new ListItem("-- Lọc: Danh Mục Gốc --", "Root"));
            ddlFilter.Items.Insert(0, new ListItem("-- Tất cả --", "All"));
        }

        protected void btnTimKiem_Click(object sender, EventArgs e) { LoadDanhSach(txtTimKiem.Text.Trim(), ddlFilter.SelectedValue); }
        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e) { LoadDanhSach(txtTimKiem.Text.Trim(), ddlFilter.SelectedValue); }

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
                { ShowMsg("Thêm thành công!", true); ResetForm(); }
            }
            else
            {
                Array.Resize(ref p, p.Length + 1);
                p[p.Length - 1] = new SqlParameter("@ID", hdfID.Value);
                if (db.ExecuteQuery("UPDATE DanhMuc SET TenDanhMuc=@Ten, MaDanhMucCha=@Cha WHERE MaDanhMuc=@ID", p))
                { ShowMsg("Cập nhật xong!", true); ResetForm(); }
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
            if ((int)db.ExecuteScalar($"SELECT COUNT(*) FROM SanPham WHERE MaDanhMuc = {id}") > 0)
            { ShowMsg("Lỗi: Danh mục này đang có sản phẩm!", false); return; }
            if ((int)db.ExecuteScalar($"SELECT COUNT(*) FROM DanhMuc WHERE MaDanhMucCha = {id}") > 0)
            { ShowMsg("Lỗi: Danh mục này đang có danh mục con!", false); return; }

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
            LoadDropdownCha(); LoadFilter();
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-2 text-center fw-bold text-success" : "d-block mt-2 text-center fw-bold text-danger";
        }

        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DanhMuc ORDER BY MaDanhMuc ASC");
                dt.TableName = "DanhMuc";
                using (StringWriter sw = new StringWriter())
                {
                    dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                    DownloadContent(sw.ToString(), "text/xml", "DanhMuc_Backup.xml");
                }
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportSQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DanhMuc ORDER BY MaDanhMuc ASC");
                string sql = GenerateInsertScript(dt, "SQLServer", "[DanhMuc]");
                DownloadContent(sql, "text/plain", "DanhMuc_SQLServer.sql");
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DanhMuc ORDER BY MaDanhMuc ASC");
                string sql = GenerateInsertScript(dt, "MySQL", "`DanhMuc`");
                DownloadContent(sql, "text/plain", "DanhMuc_MySQL.sql");
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
                    else
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

        void DownloadContent(string content, string type, string name)
        {
            try
            {
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.Buffer = true;
                Response.ContentEncoding = System.Text.Encoding.UTF8;
                Response.BinaryWrite(System.Text.Encoding.UTF8.GetPreamble());
                Response.ContentType = type;
                Response.AddHeader("Content-Disposition", "attachment; filename=" + name);
                Response.Write(content);
                Response.Flush();
                Response.SuppressContent = true;
                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
            catch { }
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
                ResetForm();
                ShowMsg("Import thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }
    }
}