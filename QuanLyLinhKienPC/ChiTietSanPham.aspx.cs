using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace QuanLyLinhKienPC
{
    public partial class ChiTietSanPham : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();
        string id = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("Default.aspx");
            }

            id = Request.QueryString["id"];

            if (!IsPostBack)
            {
                LoadChiTiet(id);
            }
        }

        void LoadChiTiet(string id)
        {
            string sql = @"SELECT sp.*, dm.TenDanhMuc, ncc.TenNCC 
                           FROM SanPham sp
                           JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc
                           JOIN NhaCungCap ncc ON sp.MaNCC = ncc.MaNCC
                           WHERE sp.MaSP = @ID";

            SqlParameter[] p = { new SqlParameter("@ID", id) };
            DataTable dt = db.GetData(sql, p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];

                lblTenSP.Text = r["TenSP"].ToString();
                lblGia.Text = string.Format("{0:N0} đ", r["GiaBan"]);
                lblDanhMuc.Text = r["TenDanhMuc"].ToString();
                lblNCC.Text = r["TenNCC"].ToString();
                lblSKU.Text = r["MaSKU"].ToString();
                lblMoTa.Text = r["ThongSoKyThuat"].ToString();

                string anh = r["HinhAnh"].ToString();
                imgSP.ImageUrl = "~/Images/Products/" + (string.IsNullOrEmpty(anh) ? "no_image.png" : anh);

                // Kiểm tra tồn kho
                int tonKho = Convert.ToInt32(r["SoLuongTon"]);
                if (tonKho > 0)
                {
                    lblTinhTrang.Text = "Còn hàng (" + tonKho + ")";
                    lblTinhTrang.CssClass = "text-success fw-bold";

                    // Giới hạn số lượng nhập tối đa bằng số tồn kho
                    txtSoLuong.Attributes["max"] = tonKho.ToString();
                }
                else
                {
                    lblTinhTrang.Text = "Hết hàng";
                    lblTinhTrang.CssClass = "text-danger fw-bold";
                    btnMua.Enabled = false;
                    btnMua.Text = "TẠM HẾT HÀNG";
                    btnMua.CssClass = "btn btn-secondary w-100 fw-bold py-2";
                }
            }
        }

        protected void btnMua_Click(object sender, EventArgs e)
        {
            // 1. Kiểm tra Đăng nhập
            if (Session["User"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // 2. Lấy số lượng khách muốn mua
            int soLuongMua = 1;
            int.TryParse(txtSoLuong.Text, out soLuongMua);

            if (soLuongMua <= 0)
            {
                lblMsg.Text = "Số lượng phải lớn hơn 0!";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // 3. Kiểm tra Tồn kho trong DB (để chắc chắn)
            string sqlCheck = "SELECT SoLuongTon FROM SanPham WHERE MaSP = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", id) };
            int tonKhoHienTai = Convert.ToInt32(db.ExecuteScalar(sqlCheck, p));

            if (soLuongMua > tonKhoHienTai)
            {
                lblMsg.Text = "Kho chỉ còn " + tonKhoHienTai + " sản phẩm. Vui lòng giảm số lượng!";
                lblMsg.ForeColor = System.Drawing.Color.Red;
                return;
            }

            // 4. Thêm vào giỏ hàng (Logic giống Default.aspx nhưng custom số lượng)
            ThemVaoGioHang(id, soLuongMua);

            // 5. Chuyển hướng sang Giỏ hàng để khách xem
            Response.Redirect("GioHang.aspx");
        }

        void ThemVaoGioHang(string id, int slMua)
        {
            DataTable gioHang = Session["Cart"] as DataTable;
            if (gioHang == null)
            {
                gioHang = new DataTable();
                gioHang.Columns.Add("MaSP");
                gioHang.Columns.Add("TenSP");
                gioHang.Columns.Add("HinhAnh");
                gioHang.Columns.Add("GiaBan", typeof(decimal));
                gioHang.Columns.Add("SoLuong", typeof(int));
                gioHang.Columns.Add("ThanhTien", typeof(decimal), "SoLuong * GiaBan");
            }

            bool daCo = false;
            foreach (DataRow dr in gioHang.Rows)
            {
                if (dr["MaSP"].ToString() == id)
                {
                    dr["SoLuong"] = (int)dr["SoLuong"] + slMua; // Cộng dồn số lượng
                    daCo = true;
                    break;
                }
            }

            if (!daCo)
            {
                string sql = "SELECT * FROM SanPham WHERE MaSP = " + id;
                DataTable dtSP = db.GetData(sql);
                if (dtSP.Rows.Count > 0)
                {
                    DataRow r = dtSP.Rows[0];
                    gioHang.Rows.Add(r["MaSP"], r["TenSP"], r["HinhAnh"], r["GiaBan"], slMua);
                }
            }

            Session["Cart"] = gioHang;

            // Cập nhật icon trên menu
            int tongSL = 0;
            foreach (DataRow dr in gioHang.Rows) tongSL += (int)dr["SoLuong"];
            Session["CartCount"] = tongSL;
        }
    }
}