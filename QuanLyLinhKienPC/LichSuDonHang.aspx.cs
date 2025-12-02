using System;
using System.Data;
using System.Data.SqlClient;

namespace QuanLyLinhKienPC
{
    public partial class LichSuDonHang : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Kiểm tra đăng nhập
            if (Session["User"] == null)
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadLichSu();
            }
        }

        void LoadLichSu()
        {
            // Lấy ID người dùng hiện tại
            string userId = Session["UserID"].ToString();

            // Truy vấn đơn hàng của người đó, sắp xếp mới nhất lên đầu
            string sql = "SELECT * FROM DonHang WHERE MaNguoiDung = @ID ORDER BY NgayDat DESC";
            SqlParameter[] p = { new SqlParameter("@ID", userId) };

            DataTable dt = db.GetData(sql, p);
            gvLichSu.DataSource = dt;
            gvLichSu.DataBind();
        }
    }
}