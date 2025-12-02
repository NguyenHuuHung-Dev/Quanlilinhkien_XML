<%@ Page Title="Lịch Sử Đơn Hàng" Language="C#" MasterPageFile="~/Site.User.Master" AutoEventWireup="true" CodeBehind="LichSuDonHang.aspx.cs" Inherits="QuanLyLinhKienPC.LichSuDonHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-primary"><i class="fas fa-history me-2"></i>LỊCH SỬ MUA HÀNG</h2>
            <a href="Default.aspx" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left"></i> Tiếp tục mua sắm
            </a>
        </div>

        <div class="card shadow-sm border-0">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <asp:GridView ID="gvLichSu" runat="server" AutoGenerateColumns="False" 
                        CssClass="table table-hover align-middle mb-0" GridLines="None"
                        EmptyDataText="Bạn chưa có đơn hàng nào!">
                        
                        <Columns>
                            <asp:BoundField DataField="MaDonHang" HeaderText="Mã Đơn" ItemStyle-Font-Bold="true" />
                            
                            <asp:BoundField DataField="NgayDat" HeaderText="Ngày Đặt" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                            
                            <asp:BoundField DataField="DiaChiGiaoHang" HeaderText="Địa Chỉ Nhận" />
                            
                            <asp:BoundField DataField="TongTien" HeaderText="Tổng Tiền" DataFormatString="{0:N0} đ" ItemStyle-CssClass="fw-bold text-danger" />

                            <asp:TemplateField HeaderText="Trạng Thái">
                                <ItemTemplate>
                                    <%-- Logic hiển thị màu sắc dựa theo trạng thái --%>
                                    <span class='badge rounded-pill 
                                        <%# Eval("TrangThai").ToString() == "Mới" ? "bg-primary" : 
                                            (Eval("TrangThai").ToString() == "Đang giao hàng" ? "bg-warning text-dark" : 
                                            "bg-success") %>'>
                                        <%# Eval("TrangThai") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Chi Tiết">
                                <ItemTemplate>
                                    <%-- Nút xem chi tiết (Chúng ta sẽ làm trang này sau nếu cần) --%>
                                    <button type="button" class="btn btn-sm btn-light text-primary" title="Xem chi tiết">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <HeaderStyle CssClass="bg-light fw-bold" />
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

</asp:Content>