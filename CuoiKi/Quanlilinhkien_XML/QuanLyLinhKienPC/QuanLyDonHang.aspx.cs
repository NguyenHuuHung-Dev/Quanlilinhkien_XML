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
    public partial class QuanLyDonHang : System.Web.UI.Page
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
                LoadDonHang();
                InitAddOrderData();
            }
        }

        void LoadDonHang(string keyword = "", string status = "All")
        {
            string sql = @"SELECT dh.*, nd.HoTen 
                           FROM DonHang dh 
                           JOIN NguoiDung nd ON dh.MaNguoiDung = nd.MaNguoiDung 
                           WHERE 1=1 ";

            List<SqlParameter> paraList = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(keyword))
            {
                int idSearch;
                bool isNumber = int.TryParse(keyword, out idSearch);

                if (isNumber)
                {
                    sql += " AND dh.MaDonHang = @KeyID ";
                    paraList.Add(new SqlParameter("@KeyID", idSearch));
                }
                else
                {
                    sql += " AND nd.HoTen LIKE @KeyName ";
                    paraList.Add(new SqlParameter("@KeyName", "%" + keyword + "%"));
                }
            }

            if (status != "All")
            {
                sql += " AND dh.TrangThai = @Status ";
                paraList.Add(new SqlParameter("@Status", status));
            }

            sql += " ORDER BY dh.NgayDat DESC";

            gvDonHang.DataSource = db.GetData(sql, paraList.ToArray());
            gvDonHang.DataBind();
        }

        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            LoadDonHang(txtTimKiem.Text.Trim(), ddlFilterStatus.SelectedValue);
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDonHang(txtTimKiem.Text.Trim(), ddlFilterStatus.SelectedValue);
        }

        DataTable GetTempTable()
        {
            if (ViewState["TempOrder"] == null)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("MaSP", typeof(int));
                dt.Columns.Add("TenSP", typeof(string));
                dt.Columns.Add("SoLuong", typeof(int));
                dt.Columns.Add("DonGia", typeof(decimal));
                dt.Columns.Add("ThanhTien", typeof(decimal), "SoLuong * DonGia");
                ViewState["TempOrder"] = dt;
            }
            return (DataTable)ViewState["TempOrder"];
        }

        void InitAddOrderData()
        {
            string sqlUser = "SELECT MaNguoiDung, HoTen + ' (' + TenDangNhap + ')' as Display FROM NguoiDung WHERE MaVaiTro != 1";
            ddlKhachHang.DataSource = db.GetData(sqlUser);
            ddlKhachHang.DataTextField = "Display";
            ddlKhachHang.DataValueField = "MaNguoiDung";
            ddlKhachHang.DataBind();
            ddlKhachHang.Items.Insert(0, new ListItem("-- Chọn Khách Hàng --", "0"));

            string sqlSP = "SELECT MaSP, TenSP FROM SanPham WHERE SoLuongTon > 0";
            ddlSanPham.DataSource = db.GetData(sqlSP);
            ddlSanPham.DataTextField = "TenSP";
            ddlSanPham.DataValueField = "MaSP";
            ddlSanPham.DataBind();
            ddlSanPham.Items.Insert(0, new ListItem("-- Chọn Sản Phẩm --", "0"));
        }

        protected void btnAddProductTemp_Click(object sender, EventArgs e)
        {
            int maSP = int.Parse(ddlSanPham.SelectedValue);
            if (maSP == 0) return;

            int sl = int.Parse(txtSoLuong.Text);
            if (sl <= 0) return;

            string sqlPrice = "SELECT TenSP, GiaBan, SoLuongTon FROM SanPham WHERE MaSP = " + maSP;
            DataTable dtSP = db.GetData(sqlPrice);
            if (dtSP.Rows.Count > 0)
            {
                decimal gia = Convert.ToDecimal(dtSP.Rows[0]["GiaBan"]);
                string tenSP = dtSP.Rows[0]["TenSP"].ToString();
                int tonKho = Convert.ToInt32(dtSP.Rows[0]["SoLuongTon"]);

                if (sl > tonKho)
                {
                    ShowMsg("Không đủ hàng trong kho! (Còn: " + tonKho + ")", false);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "PopAdd", "showAddOrderModal();", true);
                    return;
                }

                DataTable dtTemp = GetTempTable();
                DataRow[] existingRows = dtTemp.Select("MaSP = " + maSP);
                if (existingRows.Length > 0)
                {
                    existingRows[0]["SoLuong"] = (int)existingRows[0]["SoLuong"] + sl;
                }
                else
                {
                    dtTemp.Rows.Add(maSP, tenSP, sl, gia);
                }

                ViewState["TempOrder"] = dtTemp;
                BindTempGrid();
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "PopAdd", "showAddOrderModal();", true);
        }

        protected void gvTempProducts_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int maSP = Convert.ToInt32(gvTempProducts.DataKeys[e.RowIndex].Value);
            DataTable dt = GetTempTable();
            DataRow[] rows = dt.Select("MaSP=" + maSP);
            if (rows.Length > 0) rows[0].Delete();
            ViewState["TempOrder"] = dt;
            BindTempGrid();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "PopAdd", "showAddOrderModal();", true);
        }

        void BindTempGrid()
        {
            DataTable dt = GetTempTable();
            gvTempProducts.DataSource = dt;
            gvTempProducts.DataBind();

            object sum = dt.Compute("Sum(ThanhTien)", "");
            lblTempTotal.Text = (sum == DBNull.Value ? 0 : Convert.ToDecimal(sum)).ToString("N0") + " đ";
        }

        protected void btnSaveOrder_Click(object sender, EventArgs e)
        {
            DataTable dtTemp = GetTempTable();
            if (dtTemp.Rows.Count == 0)
            {
                ShowMsg("Chưa chọn sản phẩm nào!", false);
                return;
            }
            if (ddlKhachHang.SelectedValue == "0")
            {
                ShowMsg("Chưa chọn khách hàng!", false);
                return;
            }

            try
            {
                int maKH = int.Parse(ddlKhachHang.SelectedValue);
                string diaChi = txtAddDiaChi.Text.Trim();
                decimal tongTien = Convert.ToDecimal(dtTemp.Compute("Sum(ThanhTien)", ""));

                string sqlOrder = @"INSERT INTO DonHang (MaNguoiDung, NgayDat, TongTien, TrangThai, DiaChiGiaoHang) 
                                    VALUES (@u, GETDATE(), @t, N'Mới', @a); SELECT SCOPE_IDENTITY();";

                SqlParameter[] p = {
                    new SqlParameter("@u", maKH),
                    new SqlParameter("@t", tongTien),
                    new SqlParameter("@a", diaChi)
                };

                int newOrderId = Convert.ToInt32(db.ExecuteScalar(sqlOrder, p));

                foreach (DataRow r in dtTemp.Rows)
                {
                    int maSP = (int)r["MaSP"];
                    int sl = (int)r["SoLuong"];
                    decimal gia = (decimal)r["DonGia"];

                    string sqlDetail = "INSERT INTO ChiTietDonHang (MaDonHang, MaSP, SoLuong, DonGia) VALUES (" + newOrderId + ", " + maSP + ", " + sl + ", " + gia + ")";
                    db.ExecuteQuery(sqlDetail);

                    string sqlStock = "UPDATE SanPham SET SoLuongTon = SoLuongTon - " + sl + " WHERE MaSP = " + maSP;
                    db.ExecuteQuery(sqlStock);
                }

                ViewState["TempOrder"] = null;
                BindTempGrid();
                txtAddDiaChi.Text = "";
                ddlKhachHang.SelectedIndex = 0;

                LoadDonHang();
                ShowMsg("Tạo đơn hàng thành công!", true);
            }
            catch (Exception ex)
            {
                ShowMsg("Lỗi tạo đơn: " + ex.Message, false);
            }
        }

        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DonHang ORDER BY NgayDat DESC");
                dt.TableName = "DonHang";
                using (StringWriter sw = new StringWriter())
                {
                    dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                    DownloadContent(sw.ToString(), "text/xml", "DonHang_Backup.xml");
                }
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }
        protected void btnExportSQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DonHang ORDER BY NgayDat DESC");
                string sql = GenerateInsertScript(dt, "SQLServer", "[DonHang]");
                DownloadContent(sql, "text/plain", "DonHang_SQLServer.sql");
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = db.GetData("SELECT * FROM DonHang ORDER BY NgayDat DESC");
                string sql = GenerateInsertScript(dt, "MySQL", "`DonHang`");
                DownloadContent(sql, "text/plain", "DonHang_MySQL.sql");
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
            if (!fileUploadImport.HasFile) { ShowMsg("Chọn file trước!", false); return; }

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
                            string sql = @"INSERT INTO DonHang (MaNguoiDung, NgayDat, TongTien, TrangThai, DiaChiGiaoHang) 
                                           VALUES (@u, @d, @t, @s, @a)";
                            SqlCommand cmd = new SqlCommand(sql, conn);
                            cmd.Parameters.AddWithValue("@u", r["MaNguoiDung"]);
                            cmd.Parameters.AddWithValue("@d", Convert.ToDateTime(r["NgayDat"]));
                            cmd.Parameters.AddWithValue("@t", r["TongTien"]);
                            cmd.Parameters.AddWithValue("@s", r["TrangThai"]);
                            cmd.Parameters.AddWithValue("@a", r["DiaChiGiaoHang"]);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
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
                LoadDonHang();
                ShowMsg("Import thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-3 text-center fw-bold text-success" : "d-block mt-3 text-center fw-bold text-danger";
        }
    }
}