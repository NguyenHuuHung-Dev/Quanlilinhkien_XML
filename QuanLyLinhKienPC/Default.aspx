<%@ Page Title="Tech Store" Language="C#" MasterPageFile="~/Site.User.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="QuanLyLinhKienPC._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        :root {
            /* Bảng màu Ocean Blue */
            --primary: #0ea5e9;       /* Sky 500 */
            --primary-dark: #0284c7;  /* Sky 600 */
            --bg-light: #f0f9ff;      /* Sky 50 */
            --text-dark: #0f172a;     /* Slate 900 */
            --text-gray: #64748b;     /* Slate 500 */
            --glass-bg: rgba(255, 255, 255, 0.85);
            --glass-border: rgba(255, 255, 255, 0.5);
        }

        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: white;
            color: var(--text-dark);
            overflow-x: hidden;
            padding-top: 70px; /* Để nội dung không bị Navbar che mất */
        }

        /* --- 1. ADVANCED NAVIGATION BAR (Port từ React) --- */
        .navbar-custom {
            position: fixed;
            top: 0; left: 0; right: 0;
            height: 70px;
            background: var(--glass-bg);
            backdrop-filter: blur(12px); /* Hiệu ứng kính mờ */
            border-bottom: 1px solid rgba(14, 165, 233, 0.15);
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Logo Area */
        .nav-logo {
            display: flex;
            align-items: center;
            cursor: pointer;
            text-decoration: none;
            color: var(--text-dark);
            font-weight: 800;
            font-size: 1.3rem;
        }
        
        .logo-icon {
            width: 40px; height: 40px;
            background: var(--primary);
            color: white;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem;
            margin-right: 10px;
            transition: transform 0.3s;
        }
        .nav-logo:hover .logo-icon { transform: rotate(12deg); }

        /* Desktop Menu */
        .nav-menu {
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .nav-link {
            position: relative;
            display: flex;
            align-items: center;
            gap: 6px;
            color: var(--text-gray);
            font-weight: 600;
            font-size: 0.95rem;
            text-decoration: none;
            transition: color 0.2s;
        }
        .nav-link i { font-size: 1rem; }
        
        .nav-link:hover, .nav-link.active { color: var(--primary); }
        
        .nav-link::after {
            content: '';
            position: absolute;
            bottom: -5px; left: 0;
            width: 0%; height: 2px;
            background: var(--primary);
            transition: width 0.3s;
        }
        .nav-link:hover::after, .nav-link.active::after { width: 100%; }

        /* Right Actions Area */
        .nav-actions {
            display: flex;
            align-items: center;
            gap: 15px;
            padding-left: 20px;
            border-left: 1px solid #e2e8f0;
        }

        /* Search Bar */
        .search-box {
            position: relative;
            display: flex;
            align-items: center;
            background: #f1f5f9;
            border-radius: 50px;
            padding: 8px 15px;
            border: 1px solid transparent;
            transition: all 0.3s;
        }
        .search-box:focus-within {
            background: white;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
        }
        .search-box input {
            border: none;
            background: transparent;
            outline: none;
            font-size: 0.9rem;
            color: var(--text-dark);
            width: 120px;
            margin-left: 8px;
            transition: width 0.3s;
        }
        .search-box input:focus { width: 180px; }
        /* --- Style mới cho các nút vừa chuyển lên --- */

/* Nút Đăng nhập Gradient đẹp mắt */
.btn-login-nav {
    padding: 8px 20px;
    background: linear-gradient(to right, #0ea5e9, #2563eb); /* Xanh biển đậm */
    color: white !important;
    border-radius: 50px;
    font-weight: 600;
    font-size: 0.9rem;
    text-decoration: none;
    box-shadow: 0 4px 10px rgba(14, 165, 233, 0.3);
    transition: all 0.3s ease;
    display: flex; align-items: center; gap: 8px;
}
.btn-login-nav:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(14, 165, 233, 0.5);
    background: linear-gradient(to right, #0284c7, #1d4ed8);
}

/* Badge số lượng giỏ hàng (Chấm đỏ) */
.badge-count {
    position: absolute;
    top: -5px; right: -5px;
    background-color: #ef4444; /* Màu đỏ */
    color: white;
    font-size: 0.7rem;
    font-weight: bold;
    width: 18px; height: 18px;
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    border: 2px solid white;
}

/* User profile khi đã đăng nhập */
.user-profile-nav {
    font-weight: 700;
    color: var(--primary-dark);
    font-size: 0.9rem;
    display: flex; align-items: center;
}

/* Ẩn thanh xanh cũ (Nếu bạn không tìm thấy code để xóa thì dùng CSS đè lên) */
/* Giả sử class cũ của thanh xanh là .header-bottom hoặc .pc-shop-bar */
.header-bottom, .pc-shop-header {
    display: none !important;
}
        /* Action Buttons (Note, Theme, Lang) */
        .btn-icon {
            width: 38px; height: 38px;
            border-radius: 50%;
            border: none;
            background: transparent;
            color: var(--text-gray);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }
        .btn-icon:hover { background: #e2e8f0; color: var(--primary); }
        
        /* Quick Note Dropdown */
        .note-dropdown {
            position: absolute;
            top: 60px; right: 0;
            width: 320px;
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            border: 1px solid #f1f5f9;
            padding: 20px;
            display: none; /* Hidden by default */
            z-index: 1100;
            animation: slideDown 0.3s ease;
        }
        .note-dropdown.show { display: block; }

        .note-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 10px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 10px;
        }
        .note-badge {
            background: #e0f2fe; color: var(--primary);
            font-size: 0.7rem; padding: 2px 8px; border-radius: 10px; font-weight: bold;
        }
        .note-area {
            width: 100%; height: 120px;
            background: #f8fafc; border: 1px solid #e2e8f0;
            border-radius: 8px; padding: 10px;
            font-size: 0.9rem; resize: none; outline: none;
        }
        .note-area:focus { border-color: var(--primary); }

        /* Mobile Toggle */
        .mobile-toggle { display: none; font-size: 1.5rem; cursor: pointer; color: var(--text-dark); }

        /* Mobile Menu */
        .mobile-menu-container {
            display: none;
            position: absolute;
            top: 70px; left: 0; right: 0;
            background: white;
            border-bottom: 1px solid #e2e8f0;
            padding: 10px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.05);
        }
        .mobile-menu-container.show { display: block; }
        .mobile-link {
            display: flex; align-items: center; gap: 10px;
            padding: 12px 15px;
            color: var(--text-dark);
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 5px;
        }
        .mobile-link:hover { background: #f1f5f9; color: var(--primary); }

        @keyframes slideDown { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        /* Responsive */
        @media (max-width: 992px) {
            .nav-menu, .nav-actions { display: none; }
            .mobile-toggle { display: block; }
        }

        /* --- 2. REST OF THE PAGE (HERO & PRODUCTS) --- */
        /* (Giữ nguyên CSS Ocean Theme phần dưới từ câu trả lời trước) */
        .hero-wrapper {
            position: relative; padding: 80px 20px;
            background: radial-gradient(circle at top right, #e0f2fe, #ffffff);
            overflow: hidden; margin-bottom: 40px;
        }
        .hero-content {
            position: relative; z-index: 10; display: grid; grid-template-columns: 1fr 1fr;
            gap: 50px; align-items: center; max-width: 1200px; margin: 0 auto;
        }
        .hero-title { font-size: 3.5rem; font-weight: 900; color: var(--text-dark); line-height: 1.1; margin-bottom: 20px; }
        .text-gradient { background: linear-gradient(135deg, var(--primary), #6366f1); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .btn-custom { padding: 12px 30px; border-radius: 12px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 10px; transition: 0.3s; border: none; cursor: pointer; }
        .btn-primary-custom { background: linear-gradient(to right, var(--primary), #3b82f6); color: white; box-shadow: 0 10px 25px -5px rgba(14, 165, 233, 0.4); }
        .btn-primary-custom:hover { transform: translateY(-3px); box-shadow: 0 15px 30px -5px rgba(14, 165, 233, 0.6); color: white; }
        .blob { position: absolute; border-radius: 50%; filter: blur(80px); opacity: 0.5; animation: float 8s infinite ease-in-out; z-index: 0; }
        .blob-1 { top: -10%; left: -5%; width: 500px; height: 500px; background: #bae6fd; }
        .blob-2 { bottom: 0%; right: -5%; width: 400px; height: 400px; background: #7dd3fc; animation-delay: 2s; }
        @keyframes float { 0% { transform: translate(0, 0) scale(1); } 50% { transform: translate(20px, -20px) scale(1.05); } 100% { transform: translate(0, 0) scale(1); } }
        
        .main-img { width: 100%; border-radius: 24px; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.15); border: 8px solid rgba(255,255,255,0.8); animation: float-img 6s ease-in-out infinite; }
        @keyframes float-img { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-15px); } }

        /* Card Styles */
        .prod-card { background: white; border: 1px solid #f1f5f9; border-radius: 16px; overflow: hidden; transition: 0.3s; position: relative; height: 100%; display: flex; flex-direction: column; }
        .prod-card:hover { transform: translateY(-10px); box-shadow: 0 20px 30px -10px rgba(14, 165, 233, 0.15); border-color: #bae6fd; }
        .prod-img-wrap { height: 220px; padding: 20px; display: flex; align-items: center; justify-content: center; position: relative; background: linear-gradient(to bottom, #f8fafc, #ffffff); }
        .prod-img-wrap img { max-height: 100%; max-width: 100%; transition: 0.4s; }
        .prod-card:hover .prod-img-wrap img { transform: scale(1.15); }
        .stock-tag { position: absolute; top: 15px; right: 15px; font-size: 0.7rem; font-weight: 700; padding: 4px 10px; border-radius: 6px; z-index: 2; text-transform: uppercase; }
        .st-ok { background: #e0f2fe; color: var(--primary-dark); }
        .st-out { background: #fef2f2; color: #ef4444; }
        .prod-body { padding: 20px; flex: 1; display: flex; flex-direction: column; }
        .prod-name { font-size: 1.1rem; font-weight: 700; color: var(--text-dark); text-decoration: none; margin-bottom: 10px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.4; }
        .prod-name:hover { color: var(--primary); }
        .prod-price { font-size: 1.25rem; font-weight: 800; color: var(--text-dark); }
        .btn-cart-circle { width: 40px; height: 40px; border-radius: 50%; background: #f1f5f9; color: var(--text-dark); border: none; display: flex; align-items: center; justify-content: center; transition: 0.2s; cursor: pointer; }
        .btn-cart-circle:hover { background: var(--primary); color: white; transform: rotate(15deg); }
        .btn-cart-circle.disabled { opacity: 0.5; cursor: not-allowed; }
        .price-row { display: flex; justify-content: space-between; align-items: center; margin-top: auto; }
        
        /* Pagination */
        .pagination .page-link { border: none; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 10px; margin: 0 5px; font-weight: 600; color: var(--text-gray); background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .pagination .page-item.active .page-link { background: var(--primary); color: white; box-shadow: 0 5px 15px rgba(14, 165, 233, 0.4); }
    </style>

   <nav class="navbar-custom">
    <div class="nav-container">
        <a href="QuanLySanPham.aspx" class="nav-logo">
            <div class="logo-icon">D</div>
            <span>Dev<span style="color: var(--primary)">Store</span></span>
        </a>

        <div class="nav-menu">
            <a href="Default.aspx" class="nav-link active"><i class="fas fa-home"></i> Trang chủ</a>
            <a href="#" class="nav-link"><i class="fas fa-microchip"></i> Linh kiện</a>
            <a href="#" class="nav-link"><i class="fas fa-newspaper"></i> Tin tức</a>
            <a href="#" class="nav-link"><i class="fas fa-envelope"></i> Liên hệ</a>
        </div>

        <div class="nav-actions">
            <div class="search-box">
                <i class="fas fa-search text-secondary"></i>
                <input type="text" id="searchInput" placeholder="Tìm kiếm..." onkeydown="handleSearch(event)" />
            </div>

            <a href="GioHang.aspx" class="btn-icon" title="Giỏ hàng" style="text-decoration: none; position: relative;">
                <i class="fas fa-shopping-cart"></i>
                <%-- Hiển thị số lượng nếu > 0 --%>
                <% if (Session["CartCount"] != null && (int)Session["CartCount"] > 0) { %>
                    <span class="badge-count"><%= Session["CartCount"] %></span>
                <% } %>
            </a>

            <% if (Session["User"] == null) { %>
                <a href="Login.aspx" class="btn-login-nav">
                    <i class="fas fa-user"></i> Đăng Nhập
                </a>
            <% } else { %>
                <div class="user-profile-nav">
                    <span>Hi, User</span> <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout">
    <i class="fas fa-sign-out-alt"></i> Đăng Xuất
</asp:LinkButton>
                </div>
            <% } %>

            <button type="button" class="btn-icon" onclick="toggleWinterMode()" title="Chế độ Mùa Đông">
                <i class="fas fa-snowflake" id="winterIcon"></i>
            </button>

            <div class="mobile-toggle" id="mobileToggle">
                <i class="fas fa-bars"></i>
            </div>
        </div>
    </div>

    <div class="mobile-menu-container" id="mobileMenu">
        <a href="Default.aspx" class="mobile-link"><i class="fas fa-home"></i> Trang chủ</a>
        <a href="GioHang.aspx" class="mobile-link"><i class="fas fa-shopping-cart"></i> Giỏ hàng</a>
        <a href="Login.aspx" class="mobile-link"><i class="fas fa-user"></i> Tài khoản</a>
    </div>
</nav>

    <div class="hero-wrapper">
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>

        <div class="hero-content">
            <div class="hero-text animate__animated animate__fadeInUp">
                <div class="badge-pill"><i class="fas fa-check-circle me-2"></i> Uy tín hàng đầu</div>
                <h1 class="hero-title">
                    Công Nghệ Dẫn Lối<br>
                    <span class="text-gradient">Tương Lai Rực Rỡ</span>
                </h1>
                <p class="hero-desc">Hệ sinh thái PC Ocean Blue mang lại sự tươi mát và hiệu năng đỉnh cao cho góc làm việc của bạn.</p>
                <div style="display:flex; gap:15px;">
                    <a href="#listProduct" class="btn-custom btn-primary-custom">Mua Ngay <i class="fas fa-arrow-right"></i></a>
                    <a href="#" class="btn-custom btn-outline-custom">Xem Demo</a>
                </div>
            </div>
            <div class="hero-img-container animate__animated animate__fadeInUp" style="animation-delay: 0.2s;">
                <img src="https://images.unsplash.com/photo-1593640408182-31c70c8268f5?q=80&w=2542&auto=format&fit=crop" class="main-img" alt="PC Setup">
            </div>
        </div>
    </div>

    <div class="container pb-5" id="listProduct">
        <div style="text-align: center; margin-bottom: 50px;">
            <h3 style="font-size: 2rem; font-weight: 800; color: var(--text-dark);">Sản Phẩm Nổi Bật</h3>
            <div style="width: 60px; height: 4px; background: var(--primary); margin: 10px auto; border-radius: 2px;"></div>
        </div>

        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
            <asp:Repeater ID="rptSanPham" runat="server" OnItemCommand="rptSanPham_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="prod-card">
                            <div class="prod-img-wrap">
                                <span class='stock-tag <%# (int)Eval("SoLuongTon") > 0 ? "st-ok" : "st-out" %>'>
                                    <%# (int)Eval("SoLuongTon") > 0 ? "In Stock" : "Sold Out" %>
                                </span>
                                <img src='<%# "Images/Products/" + (string.IsNullOrEmpty(Eval("HinhAnh").ToString()) ? "no_image.png" : Eval("HinhAnh")) %>' alt="<%# Eval("TenSP") %>">
                            </div>
                            <div class="prod-body">
                                <div style="font-size: 0.75rem; color: var(--primary); font-weight: 700; text-transform: uppercase; margin-bottom: 5px;"><%# Eval("TenDanhMuc") %></div>
                                <a href='ChiTietSanPham.aspx?id=<%# Eval("MaSP") %>' class="prod-name" title='<%# Eval("TenSP") %>'><%# Eval("TenSP") %></a>
                                <div class="price-row">
                                    <div class="prod-price"><%# string.Format("{0:N0} đ", Eval("GiaBan")) %></div>
                                    <asp:LinkButton ID="btnMua" runat="server" CommandName="AddToCart" CommandArgument='<%# Eval("MaSP") %>' CssClass='<%# "btn-cart-circle " + ((int)Eval("SoLuongTon") > 0 ? "" : "disabled") %>' Enabled='<%# (int)Eval("SoLuongTon") > 0 %>'>
                                        <i class="fas fa-plus"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="d-flex justify-content-center mt-5">
            <nav>
                <ul class="pagination">
                    <li class='page-item <%= CurrentPage == 1 ? "disabled" : "" %>'>
                        <a class="page-link" href="Default.aspx?page=1"><i class="fas fa-angle-double-left"></i></a>
                    </li>
                    <asp:Repeater ID="rptPhanTrang" runat="server">
                        <ItemTemplate>
                            <li class='page-item <%# Convert.ToInt32(Container.DataItem) == CurrentPage ? "active" : "" %>'>
                                <a class="page-link" href='Default.aspx?page=<%# Container.DataItem %>'><%# Container.DataItem %></a>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                    <li class='page-item <%= CurrentPage == TotalPages ? "disabled" : "" %>'>
                        <a class="page-link" href='Default.aspx?page=<%= TotalPages %>'><i class="fas fa-angle-double-right"></i></a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <script>
        // 1. Xử lý Quick Note (Ghi chú nhanh)
        const btnNote = document.getElementById('btnNote');
        const noteDropdown = document.getElementById('noteDropdown');
        const noteContent = document.getElementById('noteContent');

        // Load ghi chú từ LocalStorage khi tải trang
        if (noteContent) {
            noteContent.value = localStorage.getItem('quickNotes') || '';
            
            // Tự động lưu khi gõ
            noteContent.addEventListener('input', (e) => {
                localStorage.setItem('quickNotes', e.target.value);
            });
        }

        // Toggle hiển thị Note
        if (btnNote) {
            btnNote.addEventListener('click', (e) => {
                e.stopPropagation();
                noteDropdown.classList.toggle('show');
            });
        }

        // Đóng Note khi click ra ngoài
        document.addEventListener('click', (e) => {
            if (noteDropdown && !noteDropdown.contains(e.target) && e.target !== btnNote && !btnNote.contains(e.target)) {
                noteDropdown.classList.remove('show');
            }
        });

        // 2. Xử lý Mobile Menu
        const mobileToggle = document.getElementById('mobileToggle');
        const mobileMenu = document.getElementById('mobileMenu');

        if (mobileToggle) {
            mobileToggle.addEventListener('click', () => {
                mobileMenu.classList.toggle('show');
                // Đổi icon hamburger <-> close
                const icon = mobileToggle.querySelector('i');
                if (mobileMenu.classList.contains('show')) {
                    icon.classList.remove('fa-bars');
                    icon.classList.add('fa-times');
                } else {
                    icon.classList.remove('fa-times');
                    icon.classList.add('fa-bars');
                }
            });
        }

        // 3. Winter Mode Effect (Đơn giản hóa: Đổi màu Blob nền)
        function toggleWinterMode() {
            const blobs = document.querySelectorAll('.blob');
            const winterIcon = document.getElementById('winterIcon');
            
            // Check trạng thái hiện tại (giả lập)
            const isWinter = winterIcon.classList.contains('text-info');

            if (!isWinter) {
                // Bật chế độ mùa đông (Snow)
                winterIcon.classList.add('text-info'); // Đổi màu icon tuyết
                document.body.style.backgroundColor = '#f8fdff'; // Nền lạnh hơn
                // Thay đổi màu blob sang tím/xanh băng giá
                blobs.forEach(b => b.style.filter = 'hue-rotate(45deg) blur(80px)');
                alert("❄️ Winter Mode Activated! (Hiệu ứng tuyết rơi đã bật - Giả lập)");
            } else {
                // Tắt
                winterIcon.classList.remove('text-info');
                document.body.style.backgroundColor = 'white';
                blobs.forEach(b => b.style.filter = 'blur(80px)');
            }
        }
        // Xử lý sự kiện tìm kiếm khi nhấn Enter
        function handleSearch(event) {
            if (event.key === 'Enter') {
                event.preventDefault(); // Chặn reload form mặc định
                var query = document.getElementById('searchInput').value;

                if (query.trim() !== "") {
                    // Chuyển hướng sang trang TimKiem.aspx với query string
                    // Bạn cần tạo trang TimKiem.aspx để nhận biến 'q'
                    window.location.href = 'TimKiem.aspx?q=' + encodeURIComponent(query);

                    // Hoặc nếu muốn alert test thử:
                    // alert("Đang tìm kiếm: " + query);
                }
            }
        }
    </script>

</asp:Content>