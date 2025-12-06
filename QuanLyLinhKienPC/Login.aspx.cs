using System;
using System.Data;
using System.Data.SqlClient;

namespace QuanLyLinhKienPC
{
    public partial class Login : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["User"] != null)
            {
                string role = Session["Role"].ToString();
                if (role == "1") Response.Redirect("QuanLySanPham.aspx");
                else Response.Redirect("Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // 1. Kiểm tra đầu vào
            if (txtUser.Text.Trim() == "" || txtPass.Text.Trim() == "")
            {
                lblError.Text = "Vui lòng nhập đầy đủ thông tin!";
                return;
            }

            string query = "SELECT * FROM NguoiDung WHERE TenDangNhap = @User AND MatKhauHash = @Pass AND TrangThai = 1";

            SqlParameter[] p = new SqlParameter[] {
                new SqlParameter("@User", txtUser.Text.Trim()),
                new SqlParameter("@Pass", txtPass.Text.Trim()) 
            };

            // 3. Gọi DBHelper
            DataTable dt = db.GetData(query, p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];

                Session["User"] = r["HoTen"].ToString();     
                Session["UserID"] = r["MaNguoiDung"].ToString(); 
                Session["Role"] = r["MaVaiTro"].ToString(); 

                int maVaiTro = Convert.ToInt32(r["MaVaiTro"]);

                if (maVaiTro == 1)
                {
                    Response.Redirect("QuanLySanPham.aspx");
                }
                else
                {
                    Response.Redirect("Default.aspx");
                }
            }
            else
            {
                lblError.Text = "Sai tên đăng nhập hoặc mật khẩu (hoặc tài khoản bị khóa)!";
            }
        }
    }
}