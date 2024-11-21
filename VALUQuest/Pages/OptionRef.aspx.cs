using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class OptionRef : System.Web.UI.Page
    {

        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetBlock()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "select * from tbl_block where isActive=1";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string GetCategories(string blockId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select c.categoryId, c.categoryName from tbl_category c
                            left join tbl_block b on b.blockId=c.blockId
                            where b.blockId=" + blockId + " and c.isActive=1; ";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string GetSubCategories(string catId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select sc.subCatId, sc.subCatName from tbl_subcategory sc
                            left join tbl_category c on c.categoryId=sc.catId
                            left join tbl_block b on b.blockId=c.blockId
                            where sc.isActive=1 and sc.catId=" + catId + @"
                            order by sc.subCatId desc; ";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }


        [WebMethod]
        public static string GetQuestions(string catId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"select q.questionId, q.questionName from tbl_questions q where q.quesType=2 and q.catId=" + catId + ";";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

        [WebMethod]
        public static string GetOptions(string questionId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" select o.optionId, o.optionName, o.optionValue, o.refOptionId, o.optionMsg from tbl_options o where o.questionId=" + questionId + " and o.isActive=1; ";
            DataTable dt = db.ExecuteQuery(query);

            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    optionId = row["optionId"],
                    optionName = row["optionName"],
                    optionValue = row["optionValue"],
                    refOptionId = row["refOptionId"],
                    optionMsg = row["optionMsg"],

                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }


        [WebMethod]
        public static string SaveData(string optionId, string dropdownValue)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            try
            {
                string query = "";

                
                if (Convert.ToInt32(dropdownValue)==-1)
                    {
                        query = @" update tbl_options  set refOptionId=null where optionId="+optionId+";  ";
                    }
                    else
                    {
                        query = @" update tbl_options  set refOptionId="+dropdownValue+" where optionId="+optionId+";  ";
                    }

                    db.ExecuteQuery(query);
                    return "success";
                

            }
            catch (Exception)
            {
                // Log or handle exceptions as needed
                return "danger";
            }
        }



    }
}