using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace QuanLyLinhKienPC
{
    public partial class ChiTietDonHang : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();
        string orderID = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
                Response.Redirect("Login.aspx");

            if (Request.QueryString["id"] == null)
                Response.Redirect("QuanLyDonHang.aspx");

            orderID = Request.QueryString["id"];

            if (!IsPostBack)
            {
                LoadThongTinDonHang();
                LoadChiTietSanPham();
            }
        }

        void LoadThongTinDonHang()
        {
            string sql = @"SELECT dh.*, nd.HoTen, nd.TenDangNhap 
                           FROM DonHang dh 
                           JOIN NguoiDung nd ON dh.MaNguoiDung = nd.MaNguoiDung 
                           WHERE dh.MaDonHang = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", orderID) };
            DataTable dt = db.GetData(sql, p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblMaDonHang.Text = r["MaDonHang"].ToString();
                lblKhachHang.Text = r["HoTen"].ToString() + " (" + r["TenDangNhap"] + ")";
                lblNgayDat.Text = Convert.ToDateTime(r["NgayDat"]).ToString("dd/MM/yyyy HH:mm");
                lblDiaChi.Text = r["DiaChiGiaoHang"].ToString();
                lblGhiChu.Text = string.IsNullOrEmpty(r["GhiChu"].ToString()) ? "Không có" : r["GhiChu"].ToString();
                lblTongTien.Text = Convert.ToDecimal(r["TongTien"]).ToString("N0") + " đ";

                // Set trạng thái
                string status = r["TrangThai"].ToString();
                if (ddlTrangThai.Items.FindByValue(status) != null)
                    ddlTrangThai.SelectedValue = status;

                if (status == "Đã giao" || status == "Đã hủy")
                {
                    ddlTrangThai.Enabled = false;
                    btnUpdateStatus.Enabled = false;
                    btnUpdateStatus.CssClass += " disabled";
                    lblMsg.Text = "Đơn hàng đã hoàn tất, không thể chỉnh sửa.";
                    lblMsg.CssClass = "text-danger";
                }
            }
        }

        void LoadChiTietSanPham()
        {
            string sql = @"SELECT sp.TenSP, ct.SoLuong, ct.DonGia, (ct.SoLuong * ct.DonGia) as ThanhTien
                           FROM ChiTietDonHang ct
                           JOIN SanPham sp ON ct.MaSP = sp.MaSP
                           WHERE ct.MaDonHang = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", orderID) };
            gvChiTiet.DataSource = db.GetData(sql, p);
            gvChiTiet.DataBind();
        }

        protected void btnUpdateStatus_Click(object sender, EventArgs e)
        {
            try
            {
                string newStatus = ddlTrangThai.SelectedValue;

                string sqlOld = "SELECT TrangThai FROM DonHang WHERE MaDonHang = " + orderID;
                string oldStatus = db.ExecuteScalar(sqlOld).ToString();

                if (oldStatus == "Đã hủy" || oldStatus == "Đã giao")
                {
                    ShowMsg("Trạng thái cũ là kết thúc, không thể thay đổi nữa!", false);
                    return;
                }

                if (newStatus == "Đã hủy" && oldStatus != "Đã hủy")
                {
                    HoanTraKho(orderID);
                }

                string sqlUpdate = "UPDATE DonHang SET TrangThai = @TT WHERE MaDonHang = @ID";
                SqlParameter[] p = {
                    new SqlParameter("@TT", newStatus),
                    new SqlParameter("@ID", orderID)
                };
                db.ExecuteQuery(sqlUpdate, p);

                ShowMsg("Cập nhật trạng thái thành công!", true);
                LoadThongTinDonHang(); 
            }
            catch (Exception ex)
            {
                ShowMsg("Lỗi: " + ex.Message, false);
            }
        }

        void HoanTraKho(string id)
        {
            DataTable dt = db.GetData("SELECT MaSP, SoLuong FROM ChiTietDonHang WHERE MaDonHang = " + id);
            foreach (DataRow r in dt.Rows)
            {
                string sql = "UPDATE SanPham SET SoLuongTon = SoLuongTon + " + r["SoLuong"] + " WHERE MaSP = " + r["MaSP"];
                db.ExecuteQuery(sql);
            }
        }

        void ShowMsg(string msg, bool success)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = success ? "d-block mb-2 small fw-bold text-success" : "d-block mb-2 small fw-bold text-danger";
        }
    }
}