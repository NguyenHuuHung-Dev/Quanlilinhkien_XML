using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace QuanLyLinhKienPC
{
    public partial class _Default : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        public int CurrentPage = 1;
        public int TotalPages = 0;

        int PageSize = 12;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["page"] != null)
                {
                    int.TryParse(Request.QueryString["page"], out CurrentPage);
                }

                if (CurrentPage < 1) CurrentPage = 1;

                LoadSanPhamPhanTrang();
            }
        }

        void LoadSanPhamPhanTrang()
        {
            int offset = (CurrentPage - 1) * PageSize;

            string sqlData = @"
                SELECT sp.MaSP, sp.TenSP, sp.GiaBan, sp.HinhAnh, sp.SoLuongTon, dm.TenDanhMuc 
                FROM SanPham sp 
                JOIN DanhMuc dm ON sp.MaDanhMuc = dm.MaDanhMuc 
                ORDER BY sp.MaSP DESC
                OFFSET @Offset ROWS FETCH NEXT @Size ROWS ONLY";

            SqlParameter[] p = {
                new SqlParameter("@Offset", offset),
                new SqlParameter("@Size", PageSize)
            };

            DataTable dt = db.GetData(sqlData, p);
            rptSanPham.DataSource = dt;
            rptSanPham.DataBind();

            // Tính tổng số trang
            int totalProducts = Convert.ToInt32(db.ExecuteScalar("SELECT COUNT(*) FROM SanPham"));

            if (totalProducts > 0)
            {
                TotalPages = (int)Math.Ceiling((double)totalProducts / PageSize);
            }

            // Tạo danh sách trang để bind vào Repeater phân trang
            ArrayList pages = new ArrayList();
            for (int i = 1; i <= TotalPages; i++)
            {
                pages.Add(i);
            }

            rptPhanTrang.DataSource = pages;
            rptPhanTrang.DataBind();
        }

        protected void rptSanPham_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["User"] == null)
            {
                Response.Redirect("Login.aspx?returnUrl=Default.aspx");
                return;
            }

            if (e.CommandName == "AddToCart")
            {
                string id = e.CommandArgument.ToString();
                ThemVaoGioHang(id);

                Response.Redirect("Default.aspx?page=" + CurrentPage);
            }
        }
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
        void ThemVaoGioHang(string id)
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
                    dr["SoLuong"] = (int)dr["SoLuong"] + 1;
                    daCo = true;
                    break;
                }
            }

            if (!daCo)
            {
                string sql = "SELECT MaSP, TenSP, HinhAnh, GiaBan FROM SanPham WHERE MaSP = @ID";
                SqlParameter[] p = { new SqlParameter("@ID", id) };

                DataTable dtSP = db.GetData(sql, p);
                if (dtSP.Rows.Count > 0)
                {
                    DataRow r = dtSP.Rows[0];
                    gioHang.Rows.Add(r["MaSP"], r["TenSP"], r["HinhAnh"], r["GiaBan"], 1);
                }
            }

            Session["Cart"] = gioHang;

            int tongSL = 0;
            foreach (DataRow dr in gioHang.Rows) tongSL += (int)dr["SoLuong"];
            Session["CartCount"] = tongSL;
        }
    }

}