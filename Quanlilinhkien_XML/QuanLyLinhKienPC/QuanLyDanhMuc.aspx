<%@ Page Title="Quản Lý Danh Mục" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyDanhMuc.aspx.cs" Inherits="QuanLyLinhKienPC.QuanLyDanhMuc" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        .toolbar-container {
            background-color: #ffffff;
            border-radius: 12px;
            padding: 15px 20px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.04);
            margin-bottom: 20px;
        }

        .form-control-sm, .form-select-sm {
            border-color: #e2e8f0;
            background-color: #f8fafc;
        }
        .form-control-sm:focus, .form-select-sm:focus {
            background-color: #fff;
            border-color: #2563eb;
            box-shadow: none;
        }

        .btn-sm-custom {
            padding: 5px 12px;
            font-size: 0.85rem;
            font-weight: 600;
            border-radius: 6px;
        }

        .tech-card {
            background: white; border: none; border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        
        .tech-table thead { background-color: #f1f5f9; color: #475569; }
        .tech-table th { font-weight: 600; padding: 12px; border: none; font-size: 0.8rem; text-transform: uppercase; }
        .tech-table td { vertical-align: middle; padding: 10px 12px; border-bottom: 1px solid #f8fafc; font-size: 0.9rem; }
        
        .badge-root { background-color: #dbeafe; color: #1e40af; }
        .badge-sub { background-color: #f1f5f9; color: #64748b; border: 1px solid #e2e8f0; }
    </style>

    <div class="toolbar-container d-flex flex-wrap align-items-center justify-content-between gap-3">
        
        <div class="d-flex align-items-center">
            <h5 class="fw-bold text-dark m-0 me-3"><i class="fas fa-layer-group text-primary me-2"></i>QUẢN LÝ DANH MỤC</h5>
        </div>

        <div class="d-flex align-items-center flex-wrap gap-2">
            
            <div class="input-group input-group-sm" style="width: 220px;">
                <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                <asp:TextBox ID="txtTimKiem" runat="server" CssClass="form-control border-start-0" placeholder="Tìm nhanh..."></asp:TextBox>
                <asp:Button ID="btnTimKiem" runat="server" Text="Tìm" OnClick="btnTimKiem_Click" CssClass="btn btn-secondary" />
            </div>

            <div style="width: 180px;">
                <asp:DropDownList ID="ddlFilter" runat="server" CssClass="form-select form-select-sm" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
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

    <div class="row g-4">
        
        <div class="col-md-4">
            <div class="tech-card h-100">
                <div class="p-3 border-bottom bg-light bg-opacity-50">
                    <h6 class="m-0 fw-bold text-primary text-uppercase" style="font-size: 0.9rem;">
                        <i class="fas fa-pen-to-square me-2"></i><asp:Label ID="lblTieuDe" runat="server" Text="Tạo Mới / Chỉnh Sửa"></asp:Label>
                    </h6>
                </div>
                <div class="p-3">
                    <asp:HiddenField ID="hdfID" runat="server" />
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted text-uppercase" style="font-size: 0.75rem;">Tên Danh Mục <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txtTen" runat="server" CssClass="form-control form-control-sm" placeholder="Nhập tên danh mục..."></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted text-uppercase" style="font-size: 0.75rem;">Thuộc Nhóm (Cha)</label>
                        <asp:DropDownList ID="ddlCha" runat="server" CssClass="form-select form-select-sm"></asp:DropDownList>
                        <div class="form-text mt-1" style="font-size: 0.75rem;">Để trống nếu là danh mục gốc.</div>
                    </div>

                    <div class="d-grid gap-2 mt-4">
                        <asp:Button ID="btnLuu" runat="server" Text="Lưu Dữ Liệu" OnClick="btnLuu_Click" CssClass="btn btn-primary btn-sm-custom" />
                        <asp:Button ID="btnHuy" runat="server" Text="Hủy Bỏ" OnClick="btnHuy_Click" CssClass="btn btn-light border btn-sm-custom" Visible="false" />
                    </div>
                    
                    <asp:Label ID="lblMsg" runat="server" CssClass="d-block mt-3 text-center fw-bold small"></asp:Label>
                </div>
            </div>
        </div>

        <div class="col-md-8">
            <div class="tech-card">
                <div class="table-responsive">
                    <asp:GridView ID="gvDanhMuc" runat="server" AutoGenerateColumns="False" 
                        CssClass="table tech-table table-hover mb-0" GridLines="None"
                        DataKeyNames="MaDanhMuc" OnRowDeleting="gvDanhMuc_RowDeleting" OnSelectedIndexChanged="gvDanhMuc_SelectedIndexChanged">
                        
                        <Columns>
                            <asp:BoundField DataField="MaDanhMuc" HeaderText="ID" ItemStyle-Width="50px" ItemStyle-CssClass="text-center text-secondary fw-bold" HeaderStyle-CssClass="text-center" />
                            
                            <asp:BoundField DataField="TenDanhMuc" HeaderText="Tên Danh Mục" ItemStyle-CssClass="fw-bold text-dark" />
                            
                            <asp:TemplateField HeaderText="Nhóm Cha">
                                <ItemTemplate>
                                    <span class='badge rounded-pill px-2 py-1 fw-normal <%# string.IsNullOrEmpty(Eval("TenCha").ToString()) ? "badge-root" : "badge-sub" %>'>
                                        <%# string.IsNullOrEmpty(Eval("TenCha").ToString()) ? "ROOT" : Eval("TenCha") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Thao Tác" ItemStyle-Width="100px" ItemStyle-HorizontalAlign="Right">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnSua" runat="server" CommandName="Select" CssClass="btn btn-sm btn-light text-primary border me-1"><i class="fas fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton ID="btnXoa" runat="server" CommandName="Delete" CssClass="btn btn-sm btn-light text-danger border" OnClientClick="return confirm('Bạn chắc chắn muốn xóa?');"><i class="fas fa-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        
                        <EmptyDataTemplate>
                            <div class="text-center p-4 text-muted small"><p>Không tìm thấy dữ liệu.</p></div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="importModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow">
                <div class="modal-header bg-light py-2">
                    <h6 class="modal-title fw-bold text-primary"><i class="fas fa-file-import me-2"></i>Import Dữ Liệu</h6>
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
</asp:Content>