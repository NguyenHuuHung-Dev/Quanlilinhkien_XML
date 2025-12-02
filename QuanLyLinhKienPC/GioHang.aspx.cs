using System;
using System.Data;
using System.Web.UI.WebControls;

namespace QuanLyLinhKienPC
{
    public partial class GioHang : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGioHang();
            }
        }

        void LoadGioHang()
        {
            // 1. Kiểm tra Session Giỏ hàng
            if (Session["Cart"] == null)
            {
                pnlGioRong.Visible = true;
                pnlCoHang.Visible = false;
                return;
            }

            DataTable dt = (DataTable)Session["Cart"];

            if (dt.Rows.Count == 0)
            {
                pnlGioRong.Visible = true;
                pnlCoHang.Visible = false;
            }
            else
            {
                pnlGioRong.Visible = false;
                pnlCoHang.Visible = true;

                gvGioHang.DataSource = dt;
                gvGioHang.DataBind();

                // 2. Tính tổng tiền
                decimal tongTien = 0;
                foreach (DataRow r in dt.Rows)
                {
                    tongTien += Convert.ToDecimal(r["GiaBan"]) * Convert.ToInt32(r["SoLuong"]);
                }

                // Cập nhật Label Tổng tiền
                lblTamTinh.Text = string.Format("{0:N0} đ", tongTien);
                lblTongTien.Text = string.Format("{0:N0} đ", tongTien);
            }
        }

        // Xử lý nút XÓA trên từng dòng
        protected void gvGioHang_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string id = gvGioHang.DataKeys[e.RowIndex].Value.ToString();
            DataTable dt = (DataTable)Session["Cart"];

            // Tìm dòng có MaSP tương ứng để xóa
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (dt.Rows[i]["MaSP"].ToString() == id)
                {
                    dt.Rows.RemoveAt(i);
                    break;
                }
            }

            // Lưu lại Session
            Session["Cart"] = dt;
            UpdateCartCount(dt);
            LoadGioHang(); // Load lại giao diện
        }

        // Xử lý nút CẬP NHẬT GIỎ HÀNG
        protected void btnCapNhat_Click(object sender, EventArgs e)
        {
            DataTable dt = (DataTable)Session["Cart"];

            // Duyệt qua từng dòng của GridView để lấy số lượng mới từ TextBox
            foreach (GridViewRow row in gvGioHang.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    string id = gvGioHang.DataKeys[row.RowIndex].Value.ToString();
                    TextBox txtSL = (TextBox)row.FindControl("txtSoLuong");

                    int soLuongMoi = 1;
                    int.TryParse(txtSL.Text, out soLuongMoi);

                    if (soLuongMoi <= 0) soLuongMoi = 1; // Không cho nhập số âm

                    // Cập nhật vào DataTable
                    foreach (DataRow dr in dt.Rows)
                    {
                        if (dr["MaSP"].ToString() == id)
                        {
                            dr["SoLuong"] = soLuongMoi;
                            // Cập nhật lại thành tiền trong DataTable nếu cần
                            dr["ThanhTien"] = Convert.ToDecimal(dr["GiaBan"]) * soLuongMoi;
                            break;
                        }
                    }
                }
            }

            Session["Cart"] = dt;
            UpdateCartCount(dt);
            LoadGioHang();

            // Thông báo cập nhật thành công (Màu xanh Ocean)
            lblMsg.Text = "<i class='fas fa-check-circle'></i> Cập nhật thành công!";
            lblMsg.ForeColor = System.Drawing.ColorTranslator.FromHtml("#0ea5e9");
        }

        // Xử lý nút THANH TOÁN
        protected void btnThanhToan_Click(object sender, EventArgs e)
        {
            // Kiểm tra đăng nhập lại cho chắc
            if (Session["User"] == null)
            {
                // Chuyển hướng đến trang Login, sau khi login xong sẽ quay lại trang ThanhToan
                Response.Redirect("Login.aspx?returnUrl=ThanhToan.aspx");
            }
            else
            {
                Response.Redirect("ThanhToan.aspx");
            }
        }

        // Hàm phụ: Cập nhật số lượng trên Menu (Session CartCount)
        void UpdateCartCount(DataTable dt)
        {
            int tongSL = 0;
            foreach (DataRow dr in dt.Rows)
            {
                tongSL += Convert.ToInt32(dr["SoLuong"]);
            }
            Session["CartCount"] = tongSL;
        }
    }
}