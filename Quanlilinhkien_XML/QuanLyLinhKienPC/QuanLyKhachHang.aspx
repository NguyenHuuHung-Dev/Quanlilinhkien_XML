<%@ Page Title="Quản Lý Khách Hàng" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyKhachHang.aspx.cs" Inherits="QuanLyLinhKienPC.QuanLyKhachHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        /* CSS Toolbar & General */
        .toolbar-container {
            background-color: #ffffff; border-radius: 12px; padding: 15px 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04); margin-bottom: 20px;
        }
        .form-control-sm, .form-select-sm { border-color: #e2e8f0; background-color: #f8fafc; }
        .form-control-sm:focus, .form-select-sm:focus { background-color: #fff; border-color: #2563eb; }
        .btn-sm-custom { padding: 5px 12px; font-size: 0.85rem; font-weight: 600; border-radius: 6px; }

        /* Card & Table */
        .tech-card { background: white; border: none; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .tech-table thead { background-color: #f1f5f9; color: #64748b; }
        .tech-table th { font-weight: 600; text-transform: uppercase; font-size: 0.8rem; border: none; padding: 12px; }
        .tech-table td { vertical-align: middle; border-bottom: 1px solid #f8fafc; padding: 12px; color: #334155; }
        
        /* Avatar & Role */
        .avatar-circle {
            width: 36px; height: 36px; border-radius: 50%;
            background-color: #eff6ff; color: #2563eb;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 0.9rem; border: 1px solid #bfdbfe;
        }
        .role-badge { padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .role-admin { background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        .role-user { background-color: #dbeafe; color: #1e40af; border: 1px solid #bfdbfe; }
        .sub-text { font-size: 0.8rem; color: #64748b; }
    </style>

    <div class="toolbar-container d-flex flex-wrap align-items-center justify-content-between gap-3">
        <div class="d-flex align-items-center">
            <h5 class="fw-bold text-dark m-0 me-3"><i class="fas fa-users text-primary me-2"></i>QUẢN LÝ NGƯỜI DÙNG</h5>
        </div>

        <div class="d-flex align-items-center flex-wrap gap-2">
            <div class="input-group input-group-sm" style="width: 220px;">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                <asp:TextBox ID="txtTimKiem" runat="server" CssClass="form-control border-start-0" placeholder="Tên / Username..."></asp:TextBox>
                <asp:Button ID="btnTimKiem" runat="server" Text="Tìm" OnClick="btnTimKiem_Click" CssClass="btn btn-secondary" />
            </div>

            <div style="width: 150px;">
                <asp:DropDownList ID="ddlFilterRole" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterRole_SelectedIndexChanged">
                </asp:DropDownList>
            </div>

            <div class="vr mx-1 text-muted"></div>

            <div class="dropdown">
                <button class="btn btn-outline-success btn-sm-custom dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="fas fa-download me-1"></i> Xuất dữ liệu
                </button>
                <ul class="dropdown-menu shadow border-0" style="font-size: 0.9rem;">
                    <li><asp:LinkButton ID="btnExportXML" runat="server" OnClick="btnExportXML_Click" CssClass="dropdown-item"><i class="fas fa-code me-2 text-warning"></i>Chuyển đổi SQL sang XML</asp:LinkButton></li>
                    <li><asp:LinkButton ID="btnExportMySQL" runat="server" OnClick="btnExportMySQL_Click" CssClass="dropdown-item"><i class="fas fa-database me-2 text-primary"></i>Script MySQL</asp:LinkButton></li>
                </ul>
            </div>

            <button type="button" class="btn btn-primary btn-sm-custom" data-bs-toggle="modal" data-bs-target="#importModal">
                <i class="fas fa-file-import me-1"></i> Chuyển đổi XML sang SQL
            </button>
        </div>
    </div>

    <div class="tech-card">
        <div class="table-responsive">
            <asp:GridView ID="gvKhachHang" runat="server" AutoGenerateColumns="False" 
                CssClass="table tech-table table-hover mb-0" GridLines="None" 
                DataKeyNames="MaNguoiDung"> <Columns>
                    
                    <%-- CỘT 1: HỒ SƠ --%>
                    <asp:TemplateField HeaderText="Hồ Sơ">
                        <ItemTemplate>
                            <div class="d-flex align-items-center">
                                <div class="avatar-circle me-3">
                                    <%# Eval("HoTen").ToString().Substring(0,1).ToUpper() %>
                                </div>
                                <div>
                                    <div class="fw-bold text-dark" style="font-size: 0.9rem;"><%# Eval("HoTen") %></div>
                                    <div class="sub-text"><i class="far fa-envelope me-1"></i><%# Eval("Email") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- CỘT 2: TÀI KHOẢN --%>
                    <asp:TemplateField HeaderText="Thông Tin Login">
                        <ItemTemplate>
                            <div class="fw-bold text-secondary" style="font-size: 0.9rem;"><%# Eval("TenDangNhap") %></div>
                            <div class="sub-text text-primary"><i class="fas fa-phone-alt me-1"></i><%# Eval("SoDienThoai") %></div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- CỘT 3: VAI TRÒ --%>
                    <asp:TemplateField HeaderText="Phân Quyền">
                        <ItemTemplate>
                            <span class='role-badge <%# Eval("TenVaiTro").ToString() == "Quản trị viên" ? "role-admin" : "role-user" %>'>
                                <%# Eval("TenVaiTro").ToString() == "Quản trị viên" ? "ADMIN" : "MEMBER" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- CỘT 4: ĐỊA CHỈ --%>
                    <asp:TemplateField HeaderText="Địa Chỉ">
                         <ItemTemplate>
                             <span class="text-muted small" style="display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden;" title='<%# Eval("DiaChi") %>'>
                                 <%# Eval("DiaChi") %>
                             </span>
                         </ItemTemplate>
                    </asp:TemplateField>

                    <%-- CỘT 5: THAO TÁC --%>
                    <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <button type="button" class="btn btn-sm btn-light text-primary border rounded-2" title="Xem chi tiết">
                                <i class="fas fa-eye"></i>
                            </button>
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
                <EmptyDataTemplate>
                    <div class="text-center p-4 text-muted small"><p>Không tìm thấy người dùng nào.</p></div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
    
    <asp:Label ID="lblMsg" runat="server" CssClass="d-block mt-3 text-center fw-bold small"></asp:Label>

    <div class="modal fade" id="importModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light py-2">
                    <h6 class="modal-title fw-bold text-primary"><i class="fas fa-file-import me-2"></i>Import Người Dùng</h6>
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
                    <div class="alert alert-warning small mb-0 p-2">
                        <i class="fas fa-exclamation-circle me-1"></i> Lưu ý: <b>Tên đăng nhập</b> và <b>Email</b> là duy nhất. Dữ liệu trùng lặp sẽ gây lỗi.
                    </div>
                </div>
                <div class="modal-footer py-1">
                    <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Hủy</button>
                    <asp:Button ID="btnImportData" runat="server" Text="Import Ngay" OnClick="btnImportData_Click" CssClass="btn btn-primary btn-sm fw-bold" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>