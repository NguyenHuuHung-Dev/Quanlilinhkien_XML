using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace QuanLyLinhKienPC
{
    public class DBHelper
    {
        string strConn = ConfigurationManager.ConnectionStrings["PCShopConn"].ConnectionString;

        // --- BẮT BUỘC PHẢI CÓ ĐOẠN NÀY ĐỂ FILE KHÁC DÙNG ĐƯỢC ---
        public string ConnectionString
        {
            get { return strConn; }
        }
        // ------------------------

        // 1. Hàm lấy dữ liệu (SELECT)
        public DataTable GetData(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (SqlParameter p in parameters)
                        {
                            cmd.Parameters.Add((SqlParameter)((ICloneable)p).Clone());
                        }
                    }

                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        // 2. Hàm thực thi Insert/Update/Delete
        public bool ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (SqlParameter p in parameters)
                        {
                            cmd.Parameters.Add((SqlParameter)((ICloneable)p).Clone());
                        }
                    }

                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();
                    return rows > 0;
                }
            }
        }

        // 3. Hàm lấy 1 giá trị duy nhất (ExecuteScalar)
        public object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (SqlParameter p in parameters)
                        {
                            cmd.Parameters.Add((SqlParameter)((ICloneable)p).Clone());
                        }
                    }

                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }
    }
}