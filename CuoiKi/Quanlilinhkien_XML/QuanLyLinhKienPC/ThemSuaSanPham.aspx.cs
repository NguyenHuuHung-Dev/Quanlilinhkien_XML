using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace QuanLyLinhKienPC
{
    public partial class ThemSuaSanPham : System.Web.UI.Page
    {
        DBHelper db = new DBHelper();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Kiểm tra quyền Admin
            if (Session["Role"] == null || Session["Role"].ToString() != "1")
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadCombobox();

                if (Request.QueryString["id"] != null)
                {
                    string id = Request.QueryString["id"];
                    hdfID.Value = id;
                    LoadOldData(id);
                    btnLuu.Text = "Cập Nhật Sản Phẩm";
                }
            }
        }

        void LoadCombobox()
        {
            ddlDanhMuc.DataSource = db.GetData("SELECT * FROM DanhMuc");
            ddlDanhMuc.DataTextField = "TenDanhMuc";
            ddlDanhMuc.DataValueField = "MaDanhMuc";
            ddlDanhMuc.DataBind();

            ddlNCC.DataSource = db.GetData("SELECT * FROM NhaCungCap");
            ddlNCC.DataTextField = "TenNCC";
            ddlNCC.DataValueField = "MaNCC";
            ddlNCC.DataBind();
        }

        void LoadOldData(string id)
        {
            string sql = "SELECT * FROM SanPham WHERE MaSP = @ID";
            SqlParameter[] p = { new SqlParameter("@ID", id) };
            DataTable dt = db.GetData(sql, p);

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                txtTen.Text = r["TenSP"].ToString();
                txtSKU.Text = r["MaSKU"].ToString();

                // Sửa lỗi hiển thị số: Chuyển về dạng số nguyên hoặc định dạng chuẩn
                txtGia.Text = Convert.ToDecimal(r["GiaBan"]).ToString("0");
                txtSL.Text = r["SoLuongTon"].ToString();
                txtMoTa.Text = r["ThongSoKyThuat"].ToString();

                // Chọn đúng giá trị Dropdown
                if (ddlDanhMuc.Items.FindByValue(r["MaDanhMuc"].ToString()) != null)
                    ddlDanhMuc.SelectedValue = r["MaDanhMuc"].ToString();

                if (ddlNCC.Items.FindByValue(r["MaNCC"].ToString()) != null)
                    ddlNCC.SelectedValue = r["MaNCC"].ToString();

                string tenAnh = r["HinhAnh"].ToString();
                if (!string.IsNullOrEmpty(tenAnh))
                {
                    imgCurrent.ImageUrl = "~/Images/Products/" + tenAnh;
                    imgCurrent.Visible = true;
                    lblAnhCu.Text = tenAnh;
                }
            }
        }

        protected void btnLuu_Click(object sender, EventArgs e)
        {
            // --- 1. VALIDATE DỮ LIỆU (QUAN TRỌNG) ---
            if (txtTen.Text.Trim() == "")
            {
                lblMsg.Text = "Tên sản phẩm không được để trống!"; return;
            }

            decimal giaBan = 0;
            if (!decimal.TryParse(txtGia.Text, out giaBan) || giaBan < 0)
            {
                lblMsg.Text = "Giá bán phải là số hợp lệ >= 0"; return;
            }

            int soLuong = 0;
            if (!int.TryParse(txtSL.Text, out soLuong) || soLuong < 0)
            {
                lblMsg.Text = "Số lượng phải là số nguyên >= 0"; return;
            }

            // --- 2. XỬ LÝ SKU (TRÁNH TRÙNG LẶP) ---
            string sku = txtSKU.Text.Trim();
            if (string.IsNullOrEmpty(sku))
            {
                // Nếu để trống -> Tự sinh mã để không bị lỗi Unique Key
                sku = "SKU_" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }

            // --- 3. XỬ LÝ ẢNH ---
            string finalFileName = lblAnhCu.Text;
            if (fUpload.HasFile)
            {
                string fileName = DateTime.Now.Ticks.ToString() + "_" + fUpload.FileName;
                string folderPath = Server.MapPath("~/Images/Products/");
                if (!Directory.Exists(folderPath)) Directory.CreateDirectory(folderPath);

                fUpload.SaveAs(folderPath + fileName);
                finalFileName = fileName;
            }
            else if (string.IsNullOrEmpty(finalFileName))
            {
                finalFileName = "no_image.png";
            }

            // --- 4. GOM THAM SỐ ---
            SqlParameter[] p = {
                new SqlParameter("@Ten", txtTen.Text.Trim()),
                new SqlParameter("@SKU", sku), // Dùng biến sku đã xử lý
                new SqlParameter("@DM", ddlDanhMuc.SelectedValue),
                new SqlParameter("@NCC", ddlNCC.SelectedValue),
                new SqlParameter("@Gia", giaBan), // Dùng biến số đã parse
                new SqlParameter("@SL", soLuong), // Dùng biến số đã parse
                new SqlParameter("@MoTa", txtMoTa.Text),
                new SqlParameter("@Hinh", finalFileName)
            };

            try
            {
                if (hdfID.Value == "")
                {
                    // === INSERT ===
                    string sqlInsert = @"INSERT INTO SanPham (TenSP, MaSKU, MaDanhMuc, MaNCC, GiaBan, SoLuongTon, ThongSoKyThuat, HinhAnh, NgayTao) 
                                         VALUES (@Ten, @SKU, @DM, @NCC, @Gia, @SL, @MoTa, @Hinh, GETDATE())";

                    if (db.ExecuteQuery(sqlInsert, p))
                    {
                        lblMsg.Text = "Thêm mới thành công!";
                        lblMsg.ForeColor = System.Drawing.Color.Green;
                        // Reset form
                        txtTen.Text = ""; txtSKU.Text = ""; txtGia.Text = ""; txtSL.Text = ""; txtMoTa.Text = "";
                        imgCurrent.Visible = false;
                        lblAnhCu.Text = "";
                    }
                }
                else
                {
                    // === UPDATE ===
                    // Thêm tham số ID vào mảng
                    Array.Resize(ref p, p.Length + 1);
                    p[p.Length - 1] = new SqlParameter("@ID", hdfID.Value);

                    string sqlUpdate = @"UPDATE SanPham SET 
                                         TenSP=@Ten, MaSKU=@SKU, MaDanhMuc=@DM, MaNCC=@NCC, 
                                         GiaBan=@Gia, SoLuongTon=@SL, ThongSoKyThuat=@MoTa, HinhAnh=@Hinh 
                                         WHERE MaSP=@ID"; // Dùng tham số @ID

                    if (db.ExecuteQuery(sqlUpdate, p))
                    {
                        lblMsg.Text = "Cập nhật thành công!";
                        lblMsg.ForeColor = System.Drawing.Color.Green;
                        imgCurrent.ImageUrl = "~/Images/Products/" + finalFileName;
                        imgCurrent.Visible = true;
                    }
                }
            }
            catch (SqlException ex)
            {
                // Bắt lỗi trùng Mã SKU từ SQL Server
                if (ex.Number == 2627 || ex.Number == 2601)
                    lblMsg.Text = "Lỗi: Mã SKU đã tồn tại, vui lòng nhập mã khác!";
                else
                    lblMsg.Text = "Lỗi CSDL: " + ex.Message;

                lblMsg.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}