<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="QuanLyLinhKienPC.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Đăng Nhập - DevStore</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    
    <style>
        :root {
            --primary: #0ea5e9;       /* Ocean Blue */
            --primary-dark: #0284c7;
            --text-dark: #0f172a;
        }

        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f0f9ff; /* Nền xanh nhạt */
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        /* --- Background Animation (Blobs) --- */
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(60px);
            opacity: 0.6;
            animation: float 10s infinite ease-in-out;
            z-index: 0;
        }
        .blob-1 { top: -10%; left: -10%; width: 500px; height: 500px; background: #bae6fd; animation-delay: 0s; }
        .blob-2 { bottom: -10%; right: -10%; width: 400px; height: 400px; background: #7dd3fc; animation-delay: 2s; }

        @keyframes float {
            0% { transform: translate(0, 0) scale(1); }
            50% { transform: translate(20px, -20px) scale(1.05); }
            100% { transform: translate(0, 0) scale(1); }
        }

        /* --- Login Card --- */
        .login-card {
            width: 100%;
            max-width: 420px;
            padding: 40px;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.85); /* Glass effect */
            backdrop-filter: blur(12px);
            box-shadow: 0 20px 50px rgba(14, 165, 233, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.5);
            position: relative;
            z-index: 10;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo-icon {
            width: 50px; height: 50px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            color: white;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 15px;
            box-shadow: 0 10px 20px rgba(14, 165, 233, 0.3);
        }

        .login-title {
            font-weight: 800;
            color: var(--text-dark);
            font-size: 1.5rem;
        }

        /* Inputs */
        .form-label {
            font-weight: 600;
            font-size: 0.9rem;
            color: #64748b;
        }

        .form-control {
            padding: 12px 15px;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            font-size: 0.95rem;
            background: #f8fafc;
        }
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.1);
            background: white;
        }

        /* Input Group cho Password */
        .input-group-text {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-left: none;
            border-radius: 0 12px 12px 0;
            cursor: pointer;
            color: #94a3b8;
        }
        .input-group-text:hover { color: var(--primary); }
        
        /* Fix bo góc khi dùng input group */
        .form-control.password-field {
            border-right: none;
            border-radius: 12px 0 0 12px;
        }

        /* Button */
        .btn-login {
            background: linear-gradient(to right, var(--primary), #3b82f6);
            border: none;
            padding: 12px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1rem;
            transition: all 0.3s;
            box-shadow: 0 10px 20px -5px rgba(14, 165, 233, 0.4);
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 30px -5px rgba(14, 165, 233, 0.6);
            background: linear-gradient(to right, #0284c7, #2563eb);
        }

        .helper-links {
            display: flex;
            justify-content: space-between;
            font-size: 0.85rem;
            margin-top: 15px;
        }
        .helper-links a {
            text-decoration: none;
            color: #64748b;
            font-weight: 600;
        }
        .helper-links a:hover { color: var(--primary); }

    </style>
</head>
<body>
    
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>

    <form id="form1" runat="server">
        <div class="login-card animate__animated animate__fadeInUp">
            
            <div class="login-header">
                <div class="logo-icon">
                    <i class="fas fa-microchip"></i>
                </div>
                <h3 class="login-title">Chào mừng trở lại!</h3>
                <p class="text-muted small">Đăng nhập để quản lý hệ thống DevStore</p>
            </div>
            
            <div class="mb-4">
                <label class="form-label">Tên đăng nhập</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 rounded-start-3 ps-3 text-primary">
                        <i class="fas fa-user"></i>
                    </span>
                    <asp:TextBox ID="txtUser" runat="server" CssClass="form-control border-start-0 ps-2" 
                        placeholder="Nhập username" autocomplete="off"></asp:TextBox>
                </div>
            </div>
            
            <div class="mb-4">
                <label class="form-label">Mật khẩu</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 rounded-start-3 ps-3 text-primary">
                        <i class="fas fa-lock"></i>
                    </span>
                    
                    <%-- TextBox Mật khẩu --%>
                    <asp:TextBox ID="txtPass" runat="server" CssClass="form-control border-start-0 border-end-0 ps-2" 
                        TextMode="Password" placeholder="••••••••" ClientIDMode="Static"></asp:TextBox>
                    
                    <%-- Nút con mắt (Click vào đây gọi JS) --%>
                    <span class="input-group-text bg-white border-start-0 rounded-end-3 pe-3" 
                          onclick="togglePassword()" style="cursor: pointer;">
                        <i class="fas fa-eye" id="toggleIcon"></i>
                    </span>
                </div>
            </div>

            <asp:Label ID="lblError" runat="server" ForeColor="#ef4444" CssClass="d-block mb-3 text-center fw-bold small"></asp:Label>

            <div class="d-grid">
                <asp:Button ID="btnLogin" runat="server" Text="Đăng Nhập" OnClick="btnLogin_Click" CssClass="btn btn-primary btn-login text-white" />
            </div>

            <div class="helper-links">
                <a href="#">Quên mật khẩu?</a>
                <a href="Default.aspx">Về trang chủ</a>
            </div>

        </div>
    </form>

    <script>
        function togglePassword() {
            // Lấy thẻ input password bằng ID (ClientIDMode="Static" giúp ID không bị đổi)
            var passwordField = document.getElementById("txtPass");
            var toggleIcon = document.getElementById("toggleIcon");

            if (passwordField.type === "password") {
                passwordField.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash"); // Đổi sang icon mắt gạch chéo
            } else {
                passwordField.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye"); // Đổi về icon mắt thường
            }
        }
    </script>

</body>
</html>