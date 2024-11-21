using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class DynamicQuestion : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetQuestionDynamicData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            //            string query = @"   select
            //q.dynamicId, 'Category' quesFrom, q.questCount, q.tableId, q.quesFrom quesFromId,
            //c.categoryName as columnData
            //from tbl_dynamicQuestions q
            //left join tbl_category c on c.categoryId=q.tableId and c.isActive=1
            //where q.isActive=1 and q.quesFrom=1
            //union all
            //select
            //q.dynamicId, 'Sub Category' quesFrom, q.questCount, q.tableId, q.quesFrom quesFromId,
            //sc.subCatName as columnData
            //from tbl_dynamicQuestions q
            //left join tbl_subcategory sc on sc.subCatId=q.tableId and sc.isActive=1
            //where q.isActive=1 and q.quesFrom=2;  ;";

            string query = @"   select
q.dynamicId, 'Category' quesFrom, q.questCount, q.tableId, q.quesFrom quesFromId,
c.categoryName as columnData
from tbl_dynamicQuestions q
left join tbl_category c on c.categoryId=q.tableId and c.isActive=1
where q.isActive=1 and q.quesFrom=1 ;";

            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    dynamicId = row["dynamicId"],
                    quesFrom = row["quesFrom"],
                    questCount = row["questCount"],
                    tableId = row["tableId"],
                    quesFromId = row["quesFromId"],
                    columnData = row["columnData"],

                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }


        [WebMethod]
        public static string GetTableColumnData(string quesFrom)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = "";

            if (Convert.ToInt32(quesFrom)==1)
            {
                query = @" select c.categoryId as tableId, c.categoryName as tableData from tbl_category c 
	left join tbl_block b on b.blockId=c.blockId
	where c.isActive=1 and b.isActive=1; ";
            }
 //           else if (Convert.ToInt32(quesFrom) == 2)
 //           {
 //               query = @"  select sc.subCatId as tableId, sc.subCatName as tableData from tbl_subcategory sc 
	//left join tbl_category c on c.categoryId=sc.catId
	//left join tbl_block b on b.blockId=c.blockId
	//where c.isActive=1 and b.isActive=1 and sc.isActive=1;  ";
 //           }
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }



        [WebMethod]
        public static string AddDynamicQuestions(int quesFrom, int tableId, int questCount)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pQuesFrom = new SqlParameter("@quesFrom", quesFrom);
                SqlParameter pTableId = new SqlParameter("@tableId", tableId);
                SqlParameter pQuestCount = new SqlParameter("@questCount", questCount);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);
                SqlParameter pCreatedDate = new SqlParameter("@createdDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertDynamicQuestionData",
                    pQuesFrom,
                    pTableId,
                    pQuestCount,
                    pCreatedBy,
                    pCreatedDate);

                // Return a response
                if (rowsAffected > 0)
                {
                    return "success";
                }
                else
                {
                    return "error";
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                return "error";
            }
        }


        [WebMethod]
        public static int GetTotalQuestions(int quesFrom, int tableId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                string query = "";
                if (Convert.ToInt32(quesFrom) == 1)
                {
                    query = @" select count(*) as totalQuestionCount from tbl_questions q where q.isActive=1 and q.catId=" + tableId + " ";
                }
                //else if (Convert.ToInt32(quesFrom) == 2)
                //{
                //    query = @" select count(*) as totalQuestionCount from tbl_questions q where q.isActive=1 and q.subCatId=" + tableId + " ";
                //}
                DataTable dt = db.ExecuteQuery(query);

                int status = Convert.ToInt32(dt.Rows[0].Field<Object>("totalQuestionCount"));
                return status;

            }
            catch (Exception)
            {

                throw;
            }

        }

        [WebMethod]
        public static string DeleteData(int dynamicId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pDynamicId = new SqlParameter("@dynamicId", dynamicId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteDynamicQuestionData",
                    pDynamicId,
                    pDeletedBy,
                    pDeletedDate);

                // Return a response
                if (rowsAffected > 0)
                {
                    return "success";
                }
                else
                {
                    return "error";
                }
            }
            catch (Exception ex)
            {
                // Log the exception
                return "error";
            }
        }

    }
}