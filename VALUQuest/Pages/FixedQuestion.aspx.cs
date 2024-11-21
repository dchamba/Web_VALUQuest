using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class FixedQuestion : System.Web.UI.Page
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
        public static string GetQuestions(string blockId, string categoryId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();

            // Updated query to include isFixedOrderBy
            string query = @"SELECT q.questionId, 
                            b.blockName, 
                            c.categoryName, 
                            q.questionName,
                            (CASE WHEN q.quesType = 1 THEN 'Number' ELSE 'MCQs' END) AS quesType,
                            q.isFixed,
                            q.isFixedOrderBy  -- Include isFixedOrderBy in the query
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId AND c.isActive = 1
                     LEFT JOIN tbl_block b ON b.blockId = c.blockId AND b.isActive = 1
                     WHERE q.isActive = 1 AND c.isActive = 1 AND b.isActive = 1";

            if (Convert.ToInt32(blockId) != -1)
            {
                query += " AND b.blockId = " + blockId;
            }
            if (Convert.ToInt32(categoryId) != -1)
            {
                query += " AND q.catId = " + categoryId;
            }

            DataTable dt = db.ExecuteQuery(query);

            // Convert the DataTable to a list of objects with the new isFixedOrderBy property
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    questionId = row["questionId"],
                    blockName = row["blockName"],
                    categoryName = row["categoryName"],
                    questionName = row["questionName"],
                    quesType = row["quesType"],
                    isFixed = row["isFixed"],
                    isFixedOrderBy = row["isFixedOrderBy"] == DBNull.Value ? null : row["isFixedOrderBy"] // Include isFixedOrderBy
                });
            }

            // Convert the list to JSON format
            string json = Newtonsoft.Json.JsonConvert.SerializeObject(data);
            return json;
        }



        [WebMethod]
        public static string UpdateFixedQuestion(string questionId, string isChecked, string orderBy)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "";

            // Prepare SQL based on checkbox status
            if (Convert.ToInt32(isChecked) == -1)
            {
                query = @"UPDATE tbl_questions 
                  SET isFixed = NULL,
                      isFixedOrderBy = NULL,
                      isFixedModifiedBy = '" + HttpContext.Current.Session["userName"] + @"',
                      isFixedModifiedDate = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + @"'
                  WHERE questionId = " + questionId;
            }
            else
            {
                query = @"UPDATE tbl_questions 
                  SET isFixed = 1,
                      isFixedOrderBy = " + (string.IsNullOrEmpty(orderBy) ? "NULL" : orderBy) + @",
                      isFixedModifiedBy = '" + HttpContext.Current.Session["userName"] + @"',
                      isFixedModifiedDate = '" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + @"'
                  WHERE questionId = " + questionId;
            }

            db.ExecuteQuery(query);
            return "success";
        }


    }
}