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

            if (!IsPostBack)
            {
                LoadDonHang();
            }
        }

        // --- 1. LOAD DANH SÁCH (CÓ TÌM KIẾM & LỌC) ---
        void LoadDonHang(string keyword = "", string status = "All")
        {
            string sql = @"SELECT dh.*, nd.HoTen 
                           FROM DonHang dh 
                           JOIN NguoiDung nd ON dh.MaNguoiDung = nd.MaNguoiDung 
                           WHERE 1=1 ";

            List<SqlParameter> paraList = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(keyword))
            {
                // Tìm theo Mã đơn (số) hoặc Tên khách (chuỗi)
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

        // --- 2. CẬP NHẬT TRẠNG THÁI & HOÀN KHO (GIỮ NGUYÊN LOGIC CŨ) ---
        protected void gvDonHang_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CapNhat")
            {
                try
                {
                    int index = Convert.ToInt32(e.CommandArgument);
                    GridViewRow row = gvDonHang.Rows[index];
                    string maDonHang = gvDonHang.DataKeys[index].Value.ToString();
                    DropDownList ddl = (DropDownList)row.FindControl("ddlTrangThai");
                    string trangThaiMoi = ddl.SelectedValue;

                    string sqlGetOld = "SELECT TrangThai FROM DonHang WHERE MaDonHang = " + maDonHang;
                    string trangThaiCu = db.ExecuteScalar(sqlGetOld).ToString();

                    if (trangThaiMoi == "Đã hủy" && trangThaiCu != "Đã hủy")
                    {
                        HoanTraKho(maDonHang);
                    }

                    SqlParameter[] p = { new SqlParameter("@TT", trangThaiMoi), new SqlParameter("@ID", maDonHang) };
                    db.ExecuteQuery("UPDATE DonHang SET TrangThai = @TT WHERE MaDonHang = @ID", p);

                    ShowMsg($"Đã cập nhật đơn #{maDonHang} thành công!", true);
                    LoadDonHang(txtTimKiem.Text, ddlFilterStatus.SelectedValue);
                }
                catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
            }
        }

        void HoanTraKho(string maDonHang)
        {
            DataTable dtChiTiet = db.GetData("SELECT MaSP, SoLuong FROM ChiTietDonHang WHERE MaDonHang = " + maDonHang);
            foreach (DataRow r in dtChiTiet.Rows)
            {
                string sql = "UPDATE SanPham SET SoLuongTon = SoLuongTon + " + r["SoLuong"] + " WHERE MaSP = " + r["MaSP"];
                db.ExecuteQuery(sql);
            }
        }

        protected void gvDonHang_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DropDownList ddl = (DropDownList)e.Row.FindControl("ddlTrangThai");
                LinkButton btn = (LinkButton)e.Row.FindControl("btnCapNhat");
                string tt = ((DataRowView)e.Row.DataItem)["TrangThai"].ToString();

                if (ddl != null)
                {
                    ddl.SelectedValue = tt;
                    if (tt == "Đã hủy" || tt == "Đã giao")
                    {
                        ddl.Enabled = false; btn.Visible = false;
                        e.Row.CssClass += " table-secondary text-muted";
                    }
                    else if (tt == "Đang giao hàng")
                    {
                        ddl.Items.Remove(ddl.Items.FindByValue("Mới"));
                        ddl.CssClass += " text-warning border-warning";
                    }
                }
            }
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mt-3 text-center fw-bold text-success" : "d-block mt-3 text-center fw-bold text-danger";
        }

        // --- 3. EXPORT / IMPORT (MỚI) ---

        protected void btnExportXML_Click(object sender, EventArgs e)
        {
            // Chỉ export đơn hàng, không export chi tiết (đơn giản hóa)
            DataTable dt = db.GetData("SELECT * FROM DonHang ORDER BY NgayDat DESC");
            dt.TableName = "DonHang";
            using (StringWriter sw = new StringWriter())
            {
                dt.WriteXml(sw, XmlWriteMode.WriteSchema);
                DownloadContent(sw.ToString(), "text/xml", "DonHang_Backup.xml");
            }
        }

        protected void btnExportMySQL_Click(object sender, EventArgs e)
        {
            DataTable dt = db.GetData("SELECT * FROM DonHang ORDER BY NgayDat DESC");
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("INSERT INTO `DonHang` (`MaDonHang`, `MaNguoiDung`, `NgayDat`, `TongTien`, `TrangThai`, `DiaChiGiaoHang`) VALUES");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                string date = ((DateTime)r["NgayDat"]).ToString("yyyy-MM-dd HH:mm:ss");
                string dc = r["DiaChiGiaoHang"].ToString().Replace("'", "''");

                sb.Append($"({r["MaDonHang"]}, {r["MaNguoiDung"]}, '{date}', {r["TongTien"]}, N'{r["TrangThai"]}', N'{dc}')");
                sb.AppendLine(i < dt.Rows.Count - 1 ? "," : ";");
            }
            // Xóa chữ N trước string cho chuẩn MySQL
            DownloadContent(sb.ToString().Replace("N'", "'"), "text/plain", "DonHang_MySQL.sql");
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
                LoadDonHang();
                ShowMsg("Import thành công!", true);
            }
            catch (Exception ex) { ShowMsg("Lỗi: " + ex.Message, false); }
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