using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration; 
namespace QuanLyLinhKienPC
{
    public partial class ThanhToan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Kiểm tra Login
            if (Session["User"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            // 2. Kiểm tra Giỏ hàng
            if (Session["Cart"] == null || ((DataTable)Session["Cart"]).Rows.Count == 0)
            {
                Response.Redirect("Default.aspx");
            }
            if (!IsPostBack)
            {
                LoadThongTin();
            }
        }

        void LoadThongTin()
        {
            txtHoTen.Text = Session["User"].ToString();

            DataTable dtGioHang = (DataTable)Session["Cart"];
            rptDonHang.DataSource = dtGioHang;
            rptDonHang.DataBind();

            // Tính tổng tiền
            decimal tong = 0;
            foreach (DataRow r in dtGioHang.Rows)
            {
                tong += Convert.ToDecimal(r["GiaBan"]) * Convert.ToInt32(r["SoLuong"]);
            }
            lblTongTien.Text = string.Format("{0:N0} đ", tong);
        }

        protected void btnDatHang_Click(object sender, EventArgs e)
        {
            DataTable dtGioHang = (DataTable)Session["Cart"];
            int userID = Convert.ToInt32(Session["UserID"]); // ID người mua lấy từ lúc Login
            decimal tongTien = 0;
            foreach (DataRow r in dtGioHang.Rows)
                tongTien += Convert.ToDecimal(r["GiaBan"]) * Convert.ToInt32(r["SoLuong"]);

            string strConn = ConfigurationManager.ConnectionStrings["PCShopConn"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction(); 

                try
                {
                    // 1: LƯU BẢNG DONHANG
                    string sqlDonHang = @"INSERT INTO DonHang (MaNguoiDung, NgayDat, TongTien, TrangThai, DiaChiGiaoHang, GhiChu) 
                                          VALUES (@MaUser, GETDATE(), @Tong, N'Mới', @DiaChi, @GhiChu); 
                                          SELECT SCOPE_IDENTITY();"; 

                    SqlCommand cmdDH = new SqlCommand(sqlDonHang, conn, transaction);
                    cmdDH.Parameters.AddWithValue("@MaUser", userID);
                    cmdDH.Parameters.AddWithValue("@Tong", tongTien);
                    cmdDH.Parameters.AddWithValue("@DiaChi", txtDiaChi.Text + " - SĐT: " + txtSDT.Text);
                    cmdDH.Parameters.AddWithValue("@GhiChu", txtGhiChu.Text);

                    // Lấy mã đơn hàng vừa sinh ra
                    int maDonHang = Convert.ToInt32(cmdDH.ExecuteScalar());

                    //2: DUYỆT GIỎ HÀNG -> LƯU CHI TIẾT & TRỪ KHO
                    foreach (DataRow item in dtGioHang.Rows)
                    {
                        int maSP = Convert.ToInt32(item["MaSP"]);
                        int soLuongMua = Convert.ToInt32(item["SoLuong"]);
                        decimal donGia = Convert.ToDecimal(item["GiaBan"]);

                        // Lưu Chi Tiết
                        string sqlCT = @"INSERT INTO ChiTietDonHang (MaDonHang, MaSP, SoLuong, DonGia) 
                                         VALUES (@MaDH, @MaSP, @SL, @Gia)";
                        SqlCommand cmdCT = new SqlCommand(sqlCT, conn, transaction);
                        cmdCT.Parameters.AddWithValue("@MaDH", maDonHang);
                        cmdCT.Parameters.AddWithValue("@MaSP", maSP);
                        cmdCT.Parameters.AddWithValue("@SL", soLuongMua);
                        cmdCT.Parameters.AddWithValue("@Gia", donGia);
                        cmdCT.ExecuteNonQuery();

                        // Trừ Kho (Quan trọng!)
                        string sqlKho = "UPDATE SanPham SET SoLuongTon = SoLuongTon - @SLMua WHERE MaSP = @MaSPK";
                        SqlCommand cmdKho = new SqlCommand(sqlKho, conn, transaction);
                        cmdKho.Parameters.AddWithValue("@SLMua", soLuongMua);
                        cmdKho.Parameters.AddWithValue("@MaSPK", maSP);
                        cmdKho.ExecuteNonQuery();
                    }

                    // 3: HOÀN TẤT
                    transaction.Commit(); // Lưu tất cả thay đổi vào DB

                    // Xóa giỏ hàng
                    Session["Cart"] = null;
                    Session["CartCount"] = 0;

                    Response.Redirect("ThanhCong.aspx");
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblLoi.Text = "Lỗi đặt hàng: " + ex.Message;
                }
            }
        }
    }
}