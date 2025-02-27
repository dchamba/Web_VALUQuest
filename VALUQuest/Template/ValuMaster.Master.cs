using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Temlpate
{
    public partial class ValuMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session["userName"] = "system";

            if (!IsPostBack)
            {
                this.testVersioneAttuale.InnerText = DatabaseHelper.getCurrentVersionWorking();
            }
        }
    }
}