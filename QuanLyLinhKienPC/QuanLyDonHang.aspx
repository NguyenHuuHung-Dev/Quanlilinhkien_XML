<%@ Page Title="Quản Lý Đơn Hàng" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyDonHang.aspx.cs" Inherits="QuanLyLinhKienPC.QuanLyDonHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        .toolbar-container { background-color: #ffffff; border-radius: 12px; padding: 15px 20px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); margin-bottom: 20px; }
        .form-control-sm, .form-select-sm { border-color: #e2e8f0; background-color: #f8fafc; }
        .form-control-sm:focus, .form-select-sm:focus { background-color: #fff; border-color: #2563eb; }
        .btn-sm-custom { padding: 5px 12px; font-size: 0.85rem; font-weight: 600; border-radius: 6px; }
        .tech-card { background: white; border: none; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .tech-table thead { background-color: #f1f5f9; color: #64748b; }
        .tech-table th { font-weight: 600; text-transform: uppercase; font-size: 0.8rem; border: none; padding: 12px; }
        .tech-table td { vertical-align: middle; border-bottom: 1px solid #f8fafc; padding: 10px 12px; font-size: 0.9rem; }
        .status-badge { padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .price-text { color: #2563eb; font-weight: 700; }
        .total-badge { font-size: 1.1rem; font-weight: bold; color: #dc2626; }
    </style>

    <div class="toolbar-container d-flex flex-wrap align-items-center justify-content-between gap-3">
        <div class="d-flex align-items-center">
            <h5 class="fw-bold text-dark m-0 me-3"><i class="fas fa-file-invoice-dollar text-primary me-2"></i>QUẢN LÝ ĐƠN HÀNG</h5>
        </div>

        <div class="d-flex align-items-center flex-wrap gap-2">
            <div class="input-group input-group-sm" style="width: 200px;">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                <asp:TextBox ID="txtTimKiem" runat="server" CssClass="form-control border-start-0" placeholder="Mã đơn / Tên KH..."></asp:TextBox>
                <asp:Button ID="btnTimKiem" runat="server" Text="Tìm" OnClick="btnTimKiem_Click" CssClass="btn btn-secondary" />
            </div>

            <div style="width: 160px;">
                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                    <asp:ListItem Value="All" Selected="True">-- Tất cả --</asp:ListItem>
                    <asp:ListItem Value="Mới">⏳ Chờ duyệt</asp:ListItem>
                    <asp:ListItem Value="Đang giao hàng">🚚 Đang giao</asp:ListItem>
                    <asp:ListItem Value="Đã giao">✅ Đã giao</asp:ListItem>
                    <asp:ListItem Value="Đã hủy">❌ Đã hủy</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="vr mx-1 text-muted"></div>

            <button type="button" class="btn btn-success btn-sm-custom" data-bs-toggle="modal" data-bs-target="#addOrderModal">
                <i class="fas fa-plus-circle me-1"></i> Tạo đơn
            </button>

           <div class="dropdown">
                <button class="btn btn-outline-success btn-sm-custom dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="fas fa-download me-1"></i> Xuất dữ liệu
                </button>
                <ul class="dropdown-menu shadow border-0" style="font-size: 0.9rem;">
                    <li>
                        <asp:LinkButton ID="btnExportXML" runat="server" OnClick="btnExportXML_Click" CssClass="dropdown-item py-2" CausesValidation="false">
                            <i class="fas fa-code me-2 text-warning"></i>Chuyển đổi SQL sang XML
                        </asp:LinkButton>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <asp:LinkButton ID="btnExportSQL" runat="server" OnClick="btnExportSQL_Click" CssClass="dropdown-item py-2" CausesValidation="false">
                            <i class="fas fa-database me-2 text-primary"></i> Script SQL Server
                        </asp:LinkButton>
                    </li>
                    <li>
                        <asp:LinkButton ID="btnExportMySQL" runat="server" OnClick="btnExportMySQL_Click" CssClass="dropdown-item py-2" CausesValidation="false">
                            <i class="fas fa-server me-2 text-success"></i> Script MySQL
                        </asp:LinkButton>
                    </li>
                </ul>
            </div>

            <button type="button" class="btn btn-primary btn-sm-custom" data-bs-toggle="modal" data-bs-target="#importModal">
                <i class="fas fa-file-import me-1"></i> Chuyển đổi XML sang SQL
            </button>
        </div>
    </div>

    <div class="tech-card">
        <div class="table-responsive">
            <asp:GridView ID="gvDonHang" runat="server" AutoGenerateColumns="False" 
                CssClass="table tech-table table-hover mb-0" GridLines="None"
                DataKeyNames="MaDonHang">
                
                <Columns>
                    <asp:BoundField DataField="MaDonHang" HeaderText="Mã ĐH" ItemStyle-Width="70px" ItemStyle-CssClass="fw-bold text-secondary text-center" HeaderStyle-CssClass="text-center" />
                    
                    <asp:TemplateField HeaderText="Khách Hàng">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="bg-light rounded-circle d-flex justify-content-center align-items-center me-2 text-primary fw-bold" style="width: 32px; height: 32px; font-size: 0.75rem;">
                                    <%# Eval("HoTen").ToString().Substring(0,1) %>
                                </div>
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.85rem;"><%# Eval("HoTen") %></div>
                                    <div class="small text-muted" style="font-size: 0.75rem;"><i class="far fa-clock me-1"></i><%# Eval("NgayDat", "{0:dd/MM HH:mm}") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    
                    <asp:TemplateField HeaderText="Địa Chỉ">
                        <ItemTemplate>
                            <span class="text-muted small" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden;" title='<%# Eval("DiaChiGiaoHang") %>'>
                                <%# Eval("DiaChiGiaoHang") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} đ" ItemStyle-CssClass="price-text" />

                    <asp:TemplateField HeaderText="Trạng Thái" ItemStyle-Width="150px">
                        <ItemTemplate>
                            <span class='badge rounded-pill fw-normal px-3 py-2 
                                <%# Eval("TrangThai").ToString() == "Mới" ? "bg-info text-dark" : 
                                    Eval("TrangThai").ToString() == "Đang giao hàng" ? "bg-warning text-dark" :
                                    Eval("TrangThai").ToString() == "Đã giao" ? "bg-success" : "bg-danger" %>'>
                                <%# Eval("TrangThai") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center">
                        <ItemTemplate>
                            <a href='ChiTietDonHang.aspx?id=<%# Eval("MaDonHang") %>' class="btn btn-sm btn-light text-primary border rounded-2" title="Xem chi tiết">
                                <i class="fas fa-eye"></i>
                            </a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                
                <EmptyDataTemplate>
                    <div class="text-center p-4 text-muted small"><p>Chưa có đơn hàng nào.</p></div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
    
    <asp:Label ID="lblMsg" runat="server" CssClass="d-block mt-3 text-center fw-bold small"></asp:Label>

    <div class="modal fade" id="addOrderModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-success text-white py-2">
                    <h6 class="modal-title fw-bold"><i class="fas fa-plus-circle me-2"></i>Tạo Đơn Hàng Mới</h6>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Khách hàng:</label>
                            <asp:DropDownList ID="ddlKhachHang" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                         <div class="col-md-6">
                            <label class="form-label small fw-bold">Địa chỉ giao:</label>
                            <asp:TextBox ID="txtAddDiaChi" runat="server" CssClass="form-control form-control-sm" placeholder="Nhập địa chỉ..."></asp:TextBox>
                        </div>
                    </div>

                    <hr class="text-muted" />

                    <div class="row g-2 align-items-end mb-3 bg-light p-3 rounded">
                        <div class="col-md-6">
                            <label class="small fw-bold">Sản phẩm:</label>
                            <asp:DropDownList ID="ddlSanPham" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="small fw-bold">Số lượng:</label>
                            <asp:TextBox ID="txtSoLuong" runat="server" TextMode="Number" CssClass="form-control form-control-sm" Text="1" min="1"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <asp:Button ID="btnAddProductTemp" runat="server" Text="Thêm vào list" OnClick="btnAddProductTemp_Click" CssClass="btn btn-warning btn-sm w-100 fw-bold" />
                        </div>
                    </div>

                    <div class="table-responsive mb-3" style="max-height: 200px; overflow-y:auto;">
                        <asp:GridView ID="gvTempProducts" runat="server" AutoGenerateColumns="False" 
                            CssClass="table table-sm table-bordered mb-0" ShowHeaderWhenEmpty="true" 
                            OnRowDeleting="gvTempProducts_RowDeleting" DataKeyNames="MaSP">
                            <Columns>
                                <asp:BoundField DataField="TenSP" HeaderText="Sản phẩm" />
                                <asp:BoundField DataField="SoLuong" HeaderText="SL" />
                                <asp:BoundField DataField="DonGia" HeaderText="Giá" DataFormatString="{0:N0}" />
                                <asp:BoundField DataField="ThanhTien" HeaderText="Tổng" DataFormatString="{0:N0}" />
                                <asp:CommandField ShowDeleteButton="True" DeleteText="<i class='fas fa-trash text-danger'></i>" />
                            </Columns>
                            <EmptyDataTemplate><div class="text-center small text-muted">Chưa có sản phẩm nào được chọn.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>

                    <div class="d-flex justify-content-between align-items-center">
                        <span class="small text-muted">Tổng tiền tạm tính:</span>
                        <span class="total-badge"><asp:Label ID="lblTempTotal" runat="server" Text="0 đ"></asp:Label></span>
                    </div>
                </div>
                <div class="modal-footer py-2">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <asp:Button ID="btnSaveOrder" runat="server" Text="Lưu Đơn Hàng" OnClick="btnSaveOrder_Click" CssClass="btn btn-success btn-sm fw-bold px-4" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="importModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light py-2">
                    <h6 class="modal-title fw-bold text-primary"><i class="fas fa-file-import me-2"></i>Import Đơn Hàng</h6>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label fw-bold small">Chọn file:</label>
                        <asp:FileUpload ID="fileUploadImport" runat="server" CssClass="form-control form-control-sm" accept=".xml, .sql" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold small">Loại Import:</label>
                        <asp:DropDownList ID="ddlImportType" runat="server" CssClass="form-select form-select-sm">
                            <asp:ListItem Value="XML">File XML</asp:ListItem>
                            <asp:ListItem Value="SQL">Script SQL</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="modal-footer py-1">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <asp:Button ID="btnImportData" runat="server" Text="Import Ngay" OnClick="btnImportData_Click" CssClass="btn btn-primary btn-sm fw-bold" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showAddOrderModal() {
            var modalEl = document.getElementById('addOrderModal');
            if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                var myModal = new bootstrap.Modal(modalEl);
                myModal.show();
            }
        }
    </script>

</asp:Content>