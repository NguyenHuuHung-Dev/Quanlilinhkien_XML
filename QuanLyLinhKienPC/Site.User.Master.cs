using System;
using System.Web;
using System.Web.UI;

namespace QuanLyLinhKienPC
{
    public partial class SiteUserMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Có thể thêm logic kiểm tra trang thái active của menu tại đây nếu cần
        }

        // Hàm xử lý Đăng Xuất
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // 1. Xóa toàn bộ Session
            Session.Clear();
            Session.Abandon();

            // 2. Xóa Cookie xác thực (nếu có dùng FormsAuthentication)
            // System.Web.Security.FormsAuthentication.SignOut();

            // 3. Chuyển hướng về trang chủ hoặc trang đăng nhập
            Response.Redirect("Default.aspx");
        }
    }
}