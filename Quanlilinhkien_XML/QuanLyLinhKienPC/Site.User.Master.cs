using System;
using System.Web;
using System.Web.UI;

namespace QuanLyLinhKienPC
{
    public partial class SiteUserMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            // 1. Xóa toàn bộ Session
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}