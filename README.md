use name: admin
pass: ad12345

file: web.config thay thế chuỗi
<connectionStrings>
  <add name="PCShopConn" connectionString="Data Source=Tên- sever name- sql;Initial Catalog=QuanLyLinhKienPCDB;Integrated Security=True" providerName="System.Data.SqlClient" />
  <add name="QuanLyLinhKienPCDBEntities" connectionString="metadata=res://*/Models.PCShopModel.csdl|res://*/Models.PCShopModel.ssdl|res://*/Models.PCShopModel.msl;provider=System.Data.SqlClient;provider connection string=&quot;data source=DESKTOP-TGHEQS6;initial catalog=QuanLyLinhKienPCDB;integrated security=True;trustservercertificate=True;MultipleActiveResultSets=True;App=EntityFramework&quot;" providerName="System.Data.EntityClient" />
</connectionStrings>
