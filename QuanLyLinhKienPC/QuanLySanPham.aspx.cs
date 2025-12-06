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
    public partial class QuanLySanPham : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Kiểm tra quyền Admin
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
            {
                Response.Redirect("Login.aspx");
            }

            // Fix lỗi khi Export file
            this.Form.Target = "_self";

            if (!IsPostBack)
            {
                // Mặc định tải tất cả (từ khóa rỗng)
                LoadSanPham("");
            }
        }

        // ==========================================================
        // 1. TÌM KIẾM & HIỂN THỊ DỮ LIỆU (ĐÃ CẬP NHẬT)
        // ==========================================================

        // Sự kiện click nút Tìm kiếm
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            string keyword = txtTimKiem.Text.Trim();
            LoadSanPham(keyword);
        }

        // Hàm Load dữ liệu có tham số keyword
        void LoadSanPham(string keyword)
        {
            try
            {
                // Câu truy vấn cơ bản
                string sql = @"SELECT sp.MaSP, sp.TenSP, sp.MaSKU, sp.HinhAnh, dm.TenDanhMuc, ncc.TenNCC, sp.GiaBan, sp.SoLuongTon 
                               FROM SanPham sp 
                               JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
                               JOIN NhaCungCap ncc ON sp.MaNCC = ncc.MaNCC
                               WHERE 1=1 "; // Kỹ thuật để dễ nối chuỗi động

                List<SqlParameter> paramList = new List<SqlParameter>();

                // Nếu có từ khóa -> Thêm điều kiện lọc
                if (!string.IsNullOrEmpty(keyword))
                {
                    sql += @" AND (sp.TenSP LIKE @Key 
                                OR dm.TenDanhMuc LIKE @Key 
                                OR ncc.TenNCC LIKE @Key 
                                OR sp.MaSKU LIKE @Key)";

                    // Thêm dấu % để tìm gần đúng
                    paramList.Add(new SqlParameter("@Key", "%" + keyword + "%"));
                }

                sql += " ORDER BY sp.MaSP DESC";

                // Gọi DBHelper (Truyền danh sách tham số vào)
                DataTable dt = db.GetData(sql, paramList.ToArray());

                gvSanPham.DataSource = dt;
                gvSanPham.DataBind();

                CalculateDashboard(dt); // Tính toán lại số liệu
            }
            catch (Exception ex)
            {
                ShowError("Lỗi tải dữ liệu: " + ex.Message);
            }
        }

        void CalculateDashboard(DataTable dt)
        {
            try
            {
                if (dt == null || dt.Rows.Count == 0)
                {
                    lblTotalPrd.Text = "0";
                    lblLowStock.Text = "0";
                    lblTotalValue.Text = "0";
                    return;
                }

                lblTotalPrd.Text = dt.Rows.Count.ToString();
                DataRow[] lowStockRows = dt.Select("SoLuongTon < 10");
                lblLowStock.Text = lowStockRows.Length.ToString();

                decimal totalValue = 0;
                foreach (DataRow row in dt.Rows)
                {
                    decimal price = row["GiaBan"] != DBNull.Value ? Convert.ToDecimal(row["GiaBan"]) : 0;
                    int quantity = row["SoLuongTon"] != DBNull.Value ? Convert.ToInt32(row["SoLuongTon"]) : 0;
                    totalValue += (price * quantity);
                }
                lblTotalValue.Text = totalValue.ToString("N0");
            }
            catch
            {
                lblTotalValue.Text = "Error";
            }
        }

        // ==========================================================
        // 2. XÓA SẢN PHẨM (CẬP NHẬT ĐỂ GIỮ LẠI KẾT QUẢ TÌM KIẾM)
        // ==========================================================
        protected void gvSanPham_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                if (gvSanPham.DataKeys[e.RowIndex].Value == null) return;
                string id = gvSanPham.DataKeys[e.RowIndex].Value.ToString();

                string sqlCheck = "SELECT COUNT(*) FROM ChiTietDonHang WHERE MaSP = @ID";
                SqlParameter[] p = { new SqlParameter("@ID", id) };

                int count = Convert.ToInt32(db.ExecuteScalar(sqlCheck, p));

                if (count > 0)
                {
                    ShowError("Không thể xóa! Sản phẩm này đang nằm trong lịch sử đơn hàng.");
                }
                else
                {
                    string sqlDel = "DELETE FROM SanPham WHERE MaSP = @ID";
                    SqlParameter[] pDel = { new SqlParameter("@ID", id) };
                    db.ExecuteQuery(sqlDel, pDel);

                    // Load lại dữ liệu nhưng GIỮ NGUYÊN từ khóa đang tìm kiếm
                    LoadSanPham(txtTimKiem.Text.Trim());
                    ShowSuccess("Đã xóa sản phẩm khỏi hệ thống.");
                }
            }
            catch (Exception ex)
            {
                ShowError("Lỗi khi xóa: " + ex.Message);
            }
        }

        // ==========================================================
        // 3. IMPORT DỮ LIỆU (GIỮ NGUYÊN)
        // ==========================================================
        protected void btnImportData_Click(object sender, EventArgs e)
        {
            if (!fileUploadImport.HasFile)
            {
                ShowError("Vui lòng chọn file để import!");
                return;
            }

            string importType = ddlImportType.SelectedValue;

            try
            {
                if (importType == "XML")
                {
                    ProcessImportXML(fileUploadImport.PostedFile.InputStream);
                }
                else if (importType == "SQL")
                {
                    ProcessImportSQL(fileUploadImport.PostedFile.InputStream);
                }

                // Import xong thì reset tìm kiếm để hiện tất cả
                txtTimKiem.Text = "";
                LoadSanPham("");
                ShowSuccess("Nhập dữ liệu thành công!");
            }
            catch (Exception ex)
            {
                ShowError("Lỗi Import: " + ex.Message);
            }
        }

        private void ProcessImportXML(Stream fileStream)
        {
            DataSet ds = new DataSet();
            ds.ReadXml(fileStream);

            if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0) throw new Exception("File XML không có dữ liệu.");

            DataTable dt = ds.Tables[0];

            using (SqlConnection conn = new SqlConnection(db.ConnectionString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        string sql = @"INSERT INTO SanPham (TenSP, MaSKU, HinhAnh, MaDanhMuc, MaNCC, GiaBan, SoLuongTon, ThongSoKyThuat, ThoiGianBaoHanh, NgayTao) 
                                       VALUES (@TenSP, @MaSKU, @HinhAnh, @MaDanhMuc, @MaNCC, @GiaBan, @SoLuongTon, @ThongSoKyThuat, @ThoiGianBaoHanh, @NgayTao)";

                        SqlCommand cmd = new SqlCommand(sql, conn, transaction);

                        cmd.Parameters.AddWithValue("@TenSP", row["TenSP"]);
                        cmd.Parameters.AddWithValue("@MaSKU", row.Table.Columns.Contains("MaSKU") ? row["MaSKU"] : "SKU-" + Guid.NewGuid().ToString().Substring(0, 8));
                        cmd.Parameters.AddWithValue("@HinhAnh", row.Table.Columns.Contains("HinhAnh") ? row["HinhAnh"] : DBNull.Value);
                        cmd.Parameters.AddWithValue("@MaDanhMuc", row["MaDanhMuc"]);
                        cmd.Parameters.AddWithValue("@MaNCC", row["MaNCC"]);
                        cmd.Parameters.AddWithValue("@GiaBan", row["GiaBan"]);
                        cmd.Parameters.AddWithValue("@SoLuongTon", row["SoLuongTon"]);
                        cmd.Parameters.AddWithValue("@ThongSoKyThuat", row.Table.Columns.Contains("ThongSoKyThuat") ? row["ThongSoKyThuat"] : "");
                        cmd.Parameters.AddWithValue("@ThoiGianBaoHanh", row.Table.Columns.Contains("ThoiGianBaoHanh") ? row["ThoiGianBaoHanh"] : 12);
                        cmd.Parameters.AddWithValue("@NgayTao", DateTime.Now);

                        cmd.ExecuteNonQuery();
                    }
                    transaction.Commit();
                }
                catch { transaction.Rollback(); throw; }
            }
        }

        private void ProcessImportSQL(Stream fileStream)
        {
            string script = "";
            using (StreamReader reader = new StreamReader(fileStream)) { script = reader.ReadToEnd(); }

            script = script.Replace("`", "");
            string[] commands = script.Split(new char[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

            using (SqlConnection conn = new SqlConnection(db.ConnectionString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();
                try
                {
                    try { new SqlCommand("SET IDENTITY_INSERT SanPham ON", conn, transaction).ExecuteNonQuery(); } catch { }

                    foreach (string cmdText in commands)
                    {
                        if (!string.IsNullOrWhiteSpace(cmdText))
                        {
                            new SqlCommand(cmdText, conn, transaction).ExecuteNonQuery();
                        }
                    }

                    try { new SqlCommand("SET IDENTITY_INSERT SanPham OFF", conn, transaction).ExecuteNonQuery(); } catch { }
                    transaction.Commit();
                }
                catch { transaction.Rollback(); throw; }
            }
        }

        // ==========================================================
        // 4. EXPORT DỮ LIỆU (GIỮ NGUYÊN)
        // ==========================================================
        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = GetRawDataTable();
                dt.TableName = "SanPham";
                string xmlContent = "";
                using (StringWriter sw = new StringWriter())
                {
                    dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                    xmlContent = sw.ToString();
                }
                DownloadContent(xmlContent, "text/xml", "SanPham_Backup.xml");
            }
            catch (Exception ex) { ShowError(ex.Message); }
        }

        protected void btnExportSQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = GetRawDataTable();
                string sql = GenerateInsertScript(dt, "SQLServer");
                DownloadContent(sql, "text/plain", "SanPham_Backup_SQLServer.sql");
            }
            catch (Exception ex) { ShowError(ex.Message); }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = GetRawDataTable();
                string sql = GenerateInsertScript(dt, "MySQL");
                DownloadContent(sql, "text/plain", "SanPham_Backup_MySQL.sql");
            }
            catch (Exception ex) { ShowError(ex.Message); }
        }

        // --- HELPER METHODS ---
        private DataTable GetRawDataTable()
        {
            return db.GetData("SELECT * FROM SanPham");
        }

        private string GenerateInsertScript(DataTable dt, string dbType)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine($"-- SCRIPT BACKUP TỰ ĐỘNG ({dbType})");
            sb.AppendLine($"-- Ngày tạo: {DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss")}");
            sb.AppendLine("-------------------------------------------------------");

            string tableName = dbType == "MySQL" ? "`SanPham`" : "[SanPham]";

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
                    else if (val is DateTime) values += $"'{((DateTime)val).ToString("yyyy-MM-dd HH:mm:ss")}'";
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
                sb.AppendLine($"SET IDENTITY_INSERT {tableName} OFF;");
                sb.AppendLine("GO");
            }
            return sb.ToString();
        }

        private void DownloadContent(string content, string contentType, string fileName)
        {
            Response.Clear();
            Response.ClearHeaders();
            Response.Buffer = true;
            Response.Charset = "utf-8";
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            Response.BinaryWrite(System.Text.Encoding.UTF8.GetPreamble());
            Response.ContentType = contentType;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
            Response.Write(content);
            Response.Flush();
            try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
        }

        private bool IsNumber(object value)
        {
            return value is sbyte || value is byte || value is short || value is ushort ||
                   value is int || value is uint || value is long || value is ulong ||
                   value is float || value is double || value is decimal;
        }

        private void ShowError(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "d-block mb-3 fw-bold text-center p-2 rounded bg-danger text-white";
            lblMessage.Visible = true;
        }

        private void ShowSuccess(string msg)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "d-block mb-3 fw-bold text-center p-2 rounded bg-success text-white";
            lblMessage.Visible = true;
        }
    }
}