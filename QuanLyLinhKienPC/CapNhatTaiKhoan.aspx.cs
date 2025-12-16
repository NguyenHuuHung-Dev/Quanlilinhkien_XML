using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace QuanLyLinhKienPC
{
    public partial class CapNhatTaiKhoan : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();
        string userID = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
                Response.Redirect("Login.aspx");

            if (Request.QueryString["id"] != null)
                userID = Request.QueryString["id"].ToString();
            else
                Response.Redirect("QuanLyKhachHang.aspx");

            if (!IsPostBack)
            {
                LoadRoles();
                LoadUserInfo();
            }
        }

        void LoadRoles()
        {
            DataTable dt = db.GetData("SELECT * FROM VaiTro");
            ddlRole.DataSource = dt;
            ddlRole.DataTextField = "TenVaiTro";
            ddlRole.DataValueField = "MaVaiTro";
            ddlRole.DataBind();
        }

        void LoadUserInfo()
        {
            SqlParameter[] p = { new SqlParameter("@UserID", userID) };
            DataTable dt = db.GetData("EXEC sp_GetUserDetails @UserID", p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                lblAvatar.Text = r["FullName"].ToString().Substring(0, 1).ToUpper();
                txtUsername.Text = r["Email"].ToString(); 
                txtEmail.Text = r["Email"].ToString();

                txtPassword.Attributes.Add("value", r["PasswordHash"].ToString());

                txtHoTen.Text = r["FullName"].ToString();
                txtPhone.Text = r["Phone"].ToString();
                txtAddress.Text = r["Address"] != DBNull.Value ? r["Address"].ToString() : "";

                string roleID = r["RoleID"].ToString();
                if (ddlRole.Items.FindByValue(roleID) != null)
                    ddlRole.SelectedValue = roleID;

                chkActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = "EXEC sp_UpdateUserFull @UserID, @HoTen, @Phone, @DiaChi, @RoleID, @IsActive";
                SqlParameter[] p = {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@HoTen", txtHoTen.Text.Trim()),
                    new SqlParameter("@Phone", txtPhone.Text.Trim()),
                    new SqlParameter("@DiaChi", txtAddress.Text.Trim()),
                    new SqlParameter("@RoleID", ddlRole.SelectedValue),
                    new SqlParameter("@IsActive", chkActive.Checked)
                };

                DataTable dt = db.GetData(sql, p);
                if (dt.Rows.Count > 0)
                {
                    string msg = dt.Rows[0]["Message"].ToString();
                    bool success = Convert.ToInt32(dt.Rows[0]["Success"]) == 1;

                    lblMsg.Text = msg;
                    lblMsg.CssClass = success ? "d-block mb-3 text-center fw-bold text-success" : "d-block mb-3 text-center fw-bold text-danger";
                }
            }
            catch (Exception ex)
            {
                lblMsg.Text = "Lỗi: " + ex.Message;
                lblMsg.CssClass = "d-block mb-3 text-center fw-bold text-danger";
            }
        }
    }
}