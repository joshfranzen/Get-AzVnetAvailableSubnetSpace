using System;
using System.Management.Automation;

namespace SubnetSpacefinderWebApp
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void ExecuteInputClick(object sender, EventArgs e)
        {
            // First of all, let's clean the TextBox from any previous output
            Result.Text = string.Empty;

            //// Initialize PowerShell Engine
            var shell = PowerShell.Create();

            // Execute the script 
            try
            {
                shell.AddScript(@"C:\Users\Melinda\source\repos\SubnetSpaceFinder.ps1" + " -VnetName " + VNet.Text + " -SubscriptionName " + Subscription.Text);
                String sTemp = "";
                foreach (PSObject r in shell.Invoke())
                {
                     sTemp += r.BaseObject.ToString() + "\n";
                }
                Result.Text = sTemp;
            }
            catch (ActionPreferenceStopException Error) { Result.Text = Error.Message; }
            catch (RuntimeException Error) { Result.Text = Error.Message; };
        }
    }
}