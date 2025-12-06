<%@ Page Title="Quản Lý Sản Phẩm" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLySanPham.aspx.cs" Inherits="QuanLyLinhKienPC.QuanLySanPham" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        /* --- CSS RIÊNG CHO TRANG QUẢN LÝ SẢN PHẨM --- */
        
        /* Hiệu ứng xuất hiện mượt mà */
        .animate-fade-in { animation: fadeInUp 0.5s ease-out; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        /* Card Phong cách Tech */
        .tech-card {
            background: white; border: none; border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .tech-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(37, 99, 235, 0.15); }
        
        /* Icon Box trong Card */
        .icon-square {
            width: 50px; height: 50px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }

        /* Nút bấm Tech */
        .btn-tech { background-color: #2563eb; color: white; border: none; transition: 0.3s; }
        .btn-tech:hover { background-color: #1d4ed8; color: white; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }

        /* Bảng dữ liệu */
        .tech-table thead { background-color: #f8fafc; color: #475569; }
        .tech-table th { font-weight: 600; border-bottom: 2px solid #e2e8f0; font-size: 0.85rem; text-transform: uppercase; padding: 15px; }
        .tech-table td { vertical-align: middle; border-bottom: 1px solid #f1f5f9; padding: 12px 15px; color: #334155; }
        
        /* Badges trạng thái */
        .badge-tech { background-color: #dbeafe; color: #1e40af; font-weight: 600; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; }
        .badge-tech-danger { background-color: #fee2e2; color: #991b1b; padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 0.75rem; }
    </style>

    <div class="animate-fade-in">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold text-dark m-0"><i class="fas fa-microchip text-primary me-2"></i>KHO LINH KIỆN</h4>
            <small class="text-muted">Quản lý nhập xuất và tồn kho sản phẩm</small>
        </div>
        
        <div class="d-flex flex-grow-1 justify-content-end align-items-center gap-2 mx-4">
            <div class="input-group shadow-sm" style="max-width: 350px;">
                <span class="input-group-text bg-white border-end-0 text-muted">
                    <i class="fas fa-search"></i>
                </span>
                <asp:TextBox ID="txtTimKiem" runat="server" CssClass="form-control border-start-0 ps-0" 
                    placeholder="Tìm tên, hãng hoặc loại..." AutoPostBack="true" OnTextChanged="btnTimKiem_Click"></asp:TextBox>
                <asp:LinkButton ID="btnTimKiem" runat="server" OnClick="btnTimKiem_Click" CssClass="btn btn-primary">
                    Tìm kiếm
                </asp:LinkButton>
            </div>
        </div>

       <div class="d-flex align-items-center" style="margin-right: 2px;">
             <a href="ThemSuaSanPham.aspx" class="btn btn-tech fw-bold px-3 py-2 rounded-3">
                 <i class="fas fa-plus me-1"></i> Nhập Kho
             </a>
             </div>
                 <div class="dropdown">
                    <button class="btn btn-outline-primary fw-bold dropdown-toggle px-3 py-2 rounded-3" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown" aria-expanded="false" style="margin-right: 2px;">
                        <i class="fas fa-download me-1"></i> Xuất Dữ Liệu
                    </button>
                    <ul class="dropdown-menu shadow border-0" aria-labelledby="dropdownMenuButton1">
                        <li>
                            <asp:LinkButton ID="btnExportXML" runat="server"
                                OnClick="btnExportXML_Click"
                                CssClass="dropdown-item py-2"
                                OnClientClick="this.form.target='_blank'; showLoading();">
                                <i class="fas fa-code me-2 text-warning"></i> Xuất XML
                            </asp:LinkButton>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <asp:LinkButton ID="btnExportSQL" runat="server"
                                OnClick="btnExportSQL_Click"
                                CssClass="dropdown-item py-2"
                                OnClientClick="this.form.target='_blank'; showLoading();">
                                <i class="fas fa-database me-2 text-primary"></i> Script SQL Server
                            </asp:LinkButton>
                        </li>
                        <li>
                            <asp:LinkButton ID="btnExportMySQL" runat="server"
                                OnClick="btnExportMySQL_Click"
                                CssClass="dropdown-item py-2"
                                OnClientClick="this.form.target='_blank'; showLoading();">
                                <i class="fas fa-server me-2 text-success"></i> Script MySQL
                            </asp:LinkButton>
                        </li>
                    </ul>

                </div>

                <button type="button" class="btn btn-outline-secondary fw-bold px-3 py-2 rounded-3" data-bs-toggle="modal" data-bs-target="#importModal">
                    <i class="fas fa-file-import me-1"></i> Import
                </button>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card tech-card p-3 h-100 position-relative overflow-hidden">
                    <div class="d-flex align-items-center">
                        <div class="icon-square bg-primary bg-opacity-10 text-primary me-3">
                            <i class="fas fa-database"></i>
                        </div>
                        <div>
                            <div class="text-uppercase text-muted fw-bold" style="font-size: 0.75rem;">Tổng Linh Kiện</div>
                            <h3 class="fw-bold mb-0 text-dark">
                                <asp:Label ID="lblTotalPrd" runat="server" Text="0"></asp:Label>
                            </h3>
                        </div>
                    </div>
                    <div class="position-absolute end-0 top-0 h-100 bg-primary" style="width: 4px;"></div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card tech-card p-3 h-100 position-relative overflow-hidden">
                    <div class="d-flex align-items-center">
                        <div class="icon-square bg-warning bg-opacity-10 text-warning me-3">
                            <i class="fas fa-bolt"></i>
                        </div>
                        <div>
                            <div class="text-uppercase text-muted fw-bold" style="font-size: 0.75rem;">Sắp Hết Hàng</div>
                            <h3 class="fw-bold mb-0 text-warning">
                                <asp:Label ID="lblLowStock" runat="server" Text="0"></asp:Label>
                            </h3>
                        </div>
                    </div>
                    <div class="position-absolute end-0 top-0 h-100 bg-warning" style="width: 4px;"></div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card tech-card p-3 h-100 position-relative overflow-hidden">
                    <div class="d-flex align-items-center">
                        <div class="icon-square bg-success bg-opacity-10 text-success me-3">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div>
                            <div class="text-uppercase text-muted fw-bold" style="font-size: 0.75rem;">Tổng Định Giá</div>
                            <h3 class="fw-bold mb-0 text-success">
                                <asp:Label ID="lblTotalValue" runat="server" Text="0"></asp:Label>
                            </h3>
                        </div>
                    </div>
                    <div class="position-absolute end-0 top-0 h-100 bg-success" style="width: 4px;"></div>
                </div>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

        <div class="card tech-card p-0 overflow-hidden">
            <div class="table-responsive">
                <asp:GridView ID="gvSanPham" runat="server" CssClass="table tech-table table-hover mb-0" 
                    AutoGenerateColumns="false" GridLines="None"
                    DataKeyNames="MaSP" OnRowDeleting="gvSanPham_RowDeleting">
                    <Columns>
                        <asp:BoundField DataField="TenSP" HeaderText="Tên Sản Phẩm / Model" ItemStyle-CssClass="fw-bold text-dark" />
                        
                        <asp:TemplateField HeaderText="Phân Loại">
                             <ItemTemplate>
                                 <span class="badge bg-light text-secondary border fw-normal"><%# Eval("TenDanhMuc") %></span>
                             </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="TenNCC" HeaderText="Hãng SX" ItemStyle-CssClass="text-secondary" />
                        
                        <asp:BoundField DataField="GiaBan" HeaderText="Đơn Giá" DataFormatString="{0:N0} đ" ItemStyle-CssClass="fw-bold text-primary" />
                        
                        <asp:TemplateField HeaderText="Tồn Kho">
                            <ItemTemplate>
                                <span class='<%# (int)Eval("SoLuongTon") < 10 ? "badge-tech-danger" : "badge-tech" %>'>
                                    <%# (int)Eval("SoLuongTon") < 10 ? "Low Stock: " : "Instock: " %> <%# Eval("SoLuongTon") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="120px" ItemStyle-CssClass="text-end pe-4">
                            <ItemTemplate>
                                <a href='ThemSuaSanPham.aspx?id=<%# Eval("MaSP") %>' class="btn btn-sm btn-light text-primary border me-1" title="Chỉnh sửa">
                                    <i class="fas fa-pen"></i>
                                </a>
                                <asp:LinkButton ID="btnXoa" runat="server" CommandName="Delete" 
                                    CssClass="btn btn-sm btn-light text-danger border" 
                                    OnClientClick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');" title="Xóa">
                                    <i class="fas fa-trash"></i>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    
                    <EmptyDataTemplate>
                        <div class="text-center p-4 text-muted">
                            <i class="fas fa-box-open fa-3x mb-3 opacity-25"></i>
                            <p>Kho hàng đang trống.</p>
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <div class="modal fade" id="importModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold text-primary"><i class="fas fa-file-import me-2"></i>Nhập Dữ Liệu Vào Kho</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold">1. Chọn file dữ liệu:</label>
                            <asp:FileUpload ID="fileUploadImport" runat="server" CssClass="form-control" accept=".xml, .sql" />
                            <div class="form-text small">Hỗ trợ định dạng: <b>.xml</b> hoặc <b>.sql</b></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">2. Hình thức nhập:</label>
                            <asp:DropDownList ID="ddlImportType" runat="server" CssClass="form-select">
                                <asp:ListItem Value="XML" Selected="True">Import từ File XML (XML Data)</asp:ListItem>
                                <asp:ListItem Value="SQL">Chạy Script SQL (SQL Server)</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="alert alert-warning small mb-0">
                            <i class="fas fa-exclamation-triangle me-1"></i> Lưu ý: Dữ liệu sẽ được thêm trực tiếp vào cơ sở dữ liệu. Vui lòng kiểm tra kỹ file trước khi nhập.
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                        
                        <asp:Button ID="btnImportData" runat="server" Text="Tiến Hành Import"
                            OnClick="btnImportData_Click"
                            CssClass="btn btn-primary fw-bold"
                            OnClientClick="showLoading();" />
                    </div>
                </div>
            </div>
        </div>

    </div>
</asp:Content>