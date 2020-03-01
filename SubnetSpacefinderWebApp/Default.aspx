<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="SubnetSpacefinderWebApp.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Subnet Space Finder</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div><h1 align="center">Subnet Space Finder</h1></div>
            <p>
                <div>
                    <div>
                        <asp:Label ID="lblSub" runat="server" Width="100px" Height="20px" Text ="Subscription:" ></asp:Label>
                        <asp:TextBox ID="Subscription" runat="server" Width="600px" Height="20px" ></asp:TextBox>
                    </div>
                    <asp:Label ID = "lblBlank" runat="server" Height="10px"></asp:Label>
                    <div>
                        <asp:Label ID="lblVnet" runat="server" Width="100px" Height="20px" Text ="VNet:" ></asp:Label>
                        <asp:TextBox ID="VNet" runat="server" Width="600px" Height="20px" ></asp:TextBox>
                    </div>
                </div>
            </p>
            <asp:Button ID="Find" runat="server" Text="Execute" Width="200" onclick="ExecuteInputClick" />

            <p>Result
            <asp:TextBox ID="Result" TextMode="MultiLine" Width="100%" Height="450px" runat="server"></asp:TextBox>
            </p>

        </div>
    </form>
</body>
</html>