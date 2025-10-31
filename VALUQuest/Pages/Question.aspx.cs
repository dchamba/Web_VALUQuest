using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Utility;

namespace VALUQuest.Pages
{
    public partial class Question : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();

        private static string NormalizeDecimalValue(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            decimal parsed;
            if (decimal.TryParse(value, NumberStyles.AllowDecimalPoint, CultureInfo.GetCultureInfo("it-IT"), out parsed) ||
                decimal.TryParse(value, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out parsed))
            {
                return parsed.ToString(CultureInfo.InvariantCulture);
            }

            return value.Replace(',', '.');
        }

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
                            where b.blockId=" + blockId + " and c.isActive=1 and b.isActive=1; ";
            DataTable dt = db.ExecuteQuery(query);
            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);

            return json;
        }

    
        [WebMethod]
        public static int SaveQuestionData(string catId, string questionName, string quesType, string minValue,
        string maxValue, string unit, bool isBMI, string bmiMinValue, string bmiMaxValue)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pCatId = new SqlParameter("@catId", catId);
                SqlParameter pQuestionName = new SqlParameter("@questionName", questionName);
                SqlParameter pQuesType = new SqlParameter("@quesType", quesType);
                SqlParameter pMinValue = new SqlParameter("@minValue", NormalizeDecimalValue(minValue));
                SqlParameter pMaxValue = new SqlParameter("@maxValue", NormalizeDecimalValue(maxValue));
                SqlParameter pUnit = new SqlParameter("@unit", unit);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                // New parameters for BMI values
                SqlParameter pIsBMI = new SqlParameter("@isBMI", isBMI);
                SqlParameter pBmiMinValue = new SqlParameter("@bmiMinValue", NormalizeDecimalValue(bmiMinValue));
                SqlParameter pBmiMaxValue = new SqlParameter("@bmiMaxValue", NormalizeDecimalValue(bmiMaxValue));

                int status = 0;

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionData",
                    pCatId,
                    pQuestionName,
                    pQuesType,
                    pMinValue,
                    pMaxValue,
                    pUnit,
                    pIsBMI,        // Include isBMI in the stored procedure call
                    pBmiMinValue,  // Include bmiMinValue in the stored procedure call
                    pBmiMaxValue,  // Include bmiMaxValue in the stored procedure call
                    pCreatedBy);

                // Return a response
                if (rowsAffected > 0)
                {
                    if (Convert.ToInt32(quesType) == 1)
                    {
                        status = -1;
                    }
                    else if (Convert.ToInt32(quesType) == 2)
                    {
                        string query = @"SELECT IDENT_CURRENT('["+ DatabaseHelper.getCurrentDatabaseName() + @"].[tbl_questions]') AS LatestID; ";
                        DataTable dt = db.ExecuteQuery(query);

                        status = Convert.ToInt32(dt.Rows[0].Field<Object>("LatestID"));
                    }
                }
                else
                {
                    status = 0;
                }

                return status;
            }
            catch (Exception)
            {
                throw;
            }
        }


        [WebMethod]
        public static bool SaveOptionData(int? optionId, string optionName, string optionValue, int questionId, string optionMsg)
        {

            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            SqlParameter pOptionId = new SqlParameter("@optionId", optionId);
            SqlParameter pOptionName = new SqlParameter("@optionName", optionName);
            SqlParameter pOptionValue = new SqlParameter("@optionValue", NormalizeDecimalValue(optionValue));
            SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
            SqlParameter pOptionMsg = new SqlParameter("@optionMsg", optionMsg);
            SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);
            SqlParameter pModifiedBy = new SqlParameter("@modifiedBy", HttpContext.Current.Session["userName"]);
            SqlParameter pModifiedDate = new SqlParameter("@modifiedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


            int rowsAffected = 0;
            if (optionId.HasValue)
            {
                rowsAffected = db.ExecuteStoredProcedure("sp_UpdateOptionsData",
                pOptionId,
                pOptionName,
                pOptionValue,
                pOptionMsg,
                pModifiedBy,
                pModifiedDate);
            }
            else
            {

                rowsAffected = db.ExecuteStoredProcedure("sp_InsertOptionData",
                pOptionName,
                pOptionValue,
                pQuestionId,
                pOptionMsg,
                pCreatedBy);
            }

            bool optionSaved = false;
            // Return a response
            if (rowsAffected > 0)
            {
                optionSaved = true;
                return optionSaved;
            }
            else
            {
                return optionSaved;
            }

        }

        [WebMethod]
        public static int GetLastOptionIdFromDatabase(int questionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                string query = @" select top 1 optionId as LatestID from tbl_options o where o.questionId=" + questionId + " order by o.optionId desc; ";
                DataTable dt = db.ExecuteQuery(query);

                int status = Convert.ToInt32(dt.Rows[0].Field<Object>("LatestID"));
                return status;

            }
            catch (Exception)
            {

                throw;
            }

        }

        [WebMethod]
        public static string GetQuestionData()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" exec sp_get_showQuestions";
            DataTable dt = db.ExecuteQuery(query);
            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    blockId = row["blockId"],
                    blockName = row["blockName"],
                    questionId = row["questionId"],
                    catId = row["catId"],
                    questionName = row["questionName"],
                    quesType = row["quesType"],
                    minValue = row["minValue"],
                    maxValue = row["maxValue"],
                    unit = row["unit"],
                    options = row["options"],
                    quesTypeName = row["quesTypeName"],
                    isExcludeFromDynamicQuestion = row["isExcludeFromDynamicQuestion"],
                    isBMI = row["isBMI"],
                    bmiminValue = row["bmiminValue"],
                    bmimaxValue = row["bmimaxValue"],

                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetOptionsData(string questionId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @" select o.optionId, o.optionName, o.optionValue, o.optionMsg from tbl_options o where o.questionId=" + questionId + " and o.isActive=1; ";
            DataTable dt = db.ExecuteQuery(query);

            List<object> data = new List<object>();
            foreach (DataRow row in dt.Rows)
            {
                data.Add(new
                {
                    optionId = row["optionId"],
                    optionName = row["optionName"],
                    optionValue = row["optionValue"],
                    optionMsg = row["optionMsg"],

                });
            }

            string json = js.DataTableToJSON(dt);
            return json;
        }



        [WebMethod]
        public static int UpdateData(string questionId, string catId, string questionName, string quesType, string minValue,
        string maxValue, string unit, string isBMI, string bmiMinValue, string bmiMaxValue) // Added new parameters
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                SqlParameter pCatId = new SqlParameter("@catId", catId);
                SqlParameter pQuestionName = new SqlParameter("@questionName", questionName);
                SqlParameter pQuesType = new SqlParameter("@quesType", quesType);
                SqlParameter pMinValue = new SqlParameter("@minValue", NormalizeDecimalValue(minValue));
                SqlParameter pMaxValue = new SqlParameter("@maxValue", NormalizeDecimalValue(maxValue));
                SqlParameter pUnit = new SqlParameter("@unit", unit);
                SqlParameter pModifiedBy = new SqlParameter("@modifiedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pModifiedDate = new SqlParameter("@modifiedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Added new parameters for BMI columns
                SqlParameter pIsBMI = new SqlParameter("@isBMI", isBMI);

                SqlParameter pBMIMinValue = new SqlParameter("@bmiminValue", NormalizeDecimalValue(bmiMinValue));
                SqlParameter pBMIMaxValue = new SqlParameter("@bmimaxValue", NormalizeDecimalValue(bmiMaxValue));
                int status = 0;

                int rowsAffected = db.ExecuteStoredProcedure("sp_UpdateQuestionData",
                    pQuestionId,
                    pCatId,
                    pQuestionName,
                    pQuesType,
                    pMinValue,
                    pMaxValue,
                    pUnit,
                    pModifiedBy,
                    pModifiedDate,
                    pIsBMI,          // Passing new parameter
                    pBMIMinValue,    // Passing new parameter
                    pBMIMaxValue     // Passing new parameter
                );

                // Return a response
                if (rowsAffected > 0)
                {
                    if (Convert.ToInt32(quesType) == 1)
                    {
                        status = -1;
                    }
                    else if (Convert.ToInt32(quesType) == 2)
                    {
                        status = Convert.ToInt32(questionId);
                    }
                }
                else
                {
                    status = 0;
                }

                return status;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [WebMethod]
        public static int UpdateExcludeFromDynamicQuestion(int questionId, int isExcludeFromDynamicQuestion)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                SqlParameter pIsExcludeFromDynamicQuestion = new SqlParameter("@isExcludeFromDynamicQuestion", isExcludeFromDynamicQuestion);

                int rowsAffected = db.ExecuteStoredProcedure("sp_UpdateExcludeFromDynamicQuestion",
                    pQuestionId,
                    pIsExcludeFromDynamicQuestion);

                return rowsAffected > 0 ? 1 : 0;
            }
            catch (Exception)
            {
                throw;
            }
        }

        [WebMethod]
        public static string DeleteQuestionData(string questionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteQuestionData",
                    pQuestionId,
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

        [WebMethod]
        public static string DeleteOptionData(string optionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                SqlParameter pOptionId = new SqlParameter("@optionId", optionId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));


                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteOptionData",
                    pOptionId,
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