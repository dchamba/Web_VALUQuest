using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using VALUQuest.Pages;
using VALUQuest.Utility;
using static VALUQuest.Pages.QuestionsTreeNew;

namespace VALUQuest.Pages
{ 
    public partial class QuesTree1 : System.Web.UI.Page
    {
        static DataTabletoJSON js = new DataTabletoJSON();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetQuestionsByCategory(int categoryId)
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"SELECT questionId, questionName, c.categoryName 
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId
                     WHERE q.isActive = 1 AND q.catId = "+categoryId+"";

            DataTable dt = db.ExecuteQuery(query);

            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string GetQuestions()
        {
            Utility.DatabaseHelper db = new Utility.DatabaseHelper();
            string query = @"SELECT questionId, questionName, c.categoryName 
                     FROM tbl_questions q
                     LEFT JOIN tbl_category c ON c.categoryId = q.catId
                     WHERE q.isActive = 1";
            DataTable dt = db.ExecuteQuery(query);

            // Convert DataTable to JSON
            string json = js.DataTableToJSON(dt);
            return json;
        }

        [WebMethod]
        public static string InsertHierarchicalQuestion(int questionId, int? parentOptionId, int? parentQuestionId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                SqlParameter pParentOptionId = new SqlParameter("@parentOptionId", (object)parentOptionId ?? DBNull.Value);
                SqlParameter pParentQuestionId = new SqlParameter("@parentQuestionId", (object)parentQuestionId ?? DBNull.Value);
                SqlParameter pIsActive = new SqlParameter("@isActive", 1);
                SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeDataNew",
                    pQuestionId,
                    pParentOptionId,
                    pParentQuestionId,
                    pIsActive,
                    pCreatedBy);

                return rowsAffected > 0 ? "success" : "error";
            }
            catch (Exception ex)
            {
                // Log or display detailed error message
                Console.WriteLine("Error: " + ex.Message);
                return "error: " + ex.Message;
            }
        }

        [WebMethod]
        public static string InsertChildQuestions(int parentOptionId, int parentQuestionId, List<int> questionIds)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();
                int totalRowsInserted = 0;

                foreach (int questionId in questionIds)
                {
                    SqlParameter pQuestionId = new SqlParameter("@questionId", questionId);
                    SqlParameter pParentOptionId = new SqlParameter("@parentOptionId", (object)parentOptionId ?? DBNull.Value);
                    SqlParameter pParentQuestionId = new SqlParameter("@parentQuestionId", (object)parentQuestionId ?? DBNull.Value);
                    SqlParameter pIsActive = new SqlParameter("@isActive", 1);
                    SqlParameter pCreatedBy = new SqlParameter("@createdBy", HttpContext.Current.Session["userName"]);

                    int rowsAffected = db.ExecuteStoredProcedure("sp_InsertQuestionTreeDataNew",
                        pQuestionId,
                        pParentOptionId,
                        pParentQuestionId,
                        pIsActive,
                        pCreatedBy);

                    totalRowsInserted += rowsAffected;
                }

                return totalRowsInserted == questionIds.Count ? "success" : "partial_success";
            }
            catch (Exception ex)
            {
                return "error: " + ex.Message;
            }
        }


        [WebMethod]
        public static string GetQuestionTreeData()
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                List<QuestionTable> listQuestion = db.ExecuteQueryReturnListObject<QuestionTable>("SELECT * FROM tbl_questions WHERE isActive = 1");
                List<OptionTable> listOption = db.ExecuteQueryReturnListObject<OptionTable>("SELECT * FROM tbl_options WHERE isActive = 1");

                List<QuestionTreeTable> listQuestionTreeStructure = db.ExecuteQueryReturnListObject<QuestionTreeTable>("SELECT * FROM tbl_question_treeNew_OK WHERE isActive = 1 AND nodeLevel = 0");

                List<QuestionTable> resultTree = new List<QuestionTable>();

                foreach(QuestionTreeTable rawTreeElement in listQuestionTreeStructure)
                {
                    //Creating father node
                    QuestionTable topFather = listQuestion.Find(q => q.questionId == rawTreeElement.questionId);
                    topFather.treeNodeElement = rawTreeElement;

                    if (topFather != null)
                    {
                        //Creating child node (option and question)
                        List<OptionTable> listOptionForCurrentQuestion = listOption.Where(o => o.questionId == topFather.questionId).ToList();
                        foreach (OptionTable currentOption in listOptionForCurrentQuestion)
                        {
                            listQuestionTreeStructure.Find(o => o.parentOptionId == currentOption.optionID && o.parentQuestionId == topFather.questionId);

                            topFather.optionList.Add(currentOption);
                        }
                        //creating child node


                        resultTree.Add(topFather);
                    }
                }

                ////////////////////////////////////////
                Per ogni nodo PADRE carico la in array nodo QUESTION e aggiungo le OPTIONS

                **********
                Per ogni OPTION che aggiungo verifico se in tabella Tree c'è nodo con uguali i campi QuestionId e OptionId e FatherId e active = 1 

                Carico domanda e la aggiungo come nodo padre
                Carico option le metto come figlie
                Per ogni option*** ESEGUIRE QUESTO RICURSIVAMENTE ***
                ***********

                Ultimo Nodo sarà Domanda con tutti Option senza figli

                ////////////////////////////////////////


                // Load questions and build tree
                string questionQuery = @"exec sp_get_ramificationTest";

                DataTable questionTable = db.ExecuteQuery(questionQuery);

                // Load options
                string optionQuery = @"
            SELECT 
                o.optionId,
                o.optionName,
                o.questionId
            FROM 
                tbl_options o
            WHERE 
                o.isActive = 1;";
                DataTable optionTable = db.ExecuteQuery(optionQuery);

                // Create dictionaries for easier lookup
                Dictionary<int, dynamic> nodes = new Dictionary<int, dynamic>();
                List<dynamic> treeData = new List<dynamic>();

                // Create the static "Ramification" node
                var ramificationNode = new
                {
                    title = "Ramification",
                    key = "root_0",
                    folder = true,
                    expanded = true,
                    children = new List<dynamic>()
                };
                treeData.Add(ramificationNode);

                // Create option dictionary for lookup
                Dictionary<int, List<dynamic>> optionNodes = new Dictionary<int, List<dynamic>>();
                foreach (DataRow row in optionTable.Rows)
                {
                    int questionId = row.Field<int>("questionId");
                    int optionId = row.Field<int>("optionId");
                    string optionName = row.Field<string>("optionName");

                    var optionNode = new
                    {
                        title = optionName,
                        key = $"o_{optionId}",
                        folder = false,
                        isOption = true,
                        optionId = optionId, // Add optionId for reference
                        questionId = questionId, // Add questionId for reference
                        children = new List<dynamic>()
                    };

                    if (!optionNodes.ContainsKey(questionId))
                    {
                        optionNodes[questionId] = new List<dynamic>();
                    }
                    optionNodes[questionId].Add(optionNode);
                }

                // Iterate over the question data and build the tree structure
                foreach (DataRow questionRow in questionTable.Rows)
                {
                    int questionTreeId = questionRow.Field<int>("questionTreeId"); // Ensure questionTreeId is retrieved
                    int questionId = questionRow.Field<int>("questionId");
                    int? parentOptionId = questionRow.Field<int?>("parentOptionId");
                    int? parentQuestionId = questionRow.Field<int?>("parentQuestionId");
                    string questionTitle = questionRow.Field<string>("questionTitle");

                    var questionNode = new
                    {
                        title = questionTitle,
                        key = $"q_{questionId}",
                        folder = true,
                        isOption = false,
                        questionId = questionId, // Add questionId for reference
                        questionTreeId = questionTreeId, // Add questionTreeId for reference
                        parentOptionId = parentOptionId, // Add parentOptionId for reference
                        parentQuestionId = parentQuestionId, // Add parentQuestionId for reference
                        children = new List<dynamic>()
                    };

                    nodes[questionId] = questionNode;

                    // Add options under the question if available
                    if (optionNodes.ContainsKey(questionId))
                    {
                        foreach (var optionNode in optionNodes[questionId])
                        {
                            questionNode.children.Add(optionNode);
                        }
                    }

                    if (parentQuestionId == null && parentOptionId == null)
                    {
                        // This is a root-level question, add it to the "Ramification" node
                        ramificationNode.children.Add(questionNode);
                    }
                    else if (parentOptionId != null && nodes.ContainsKey(parentQuestionId.Value))
                    {
                        // Add question as a child of the parent option
                        var parentNode = nodes[parentQuestionId.Value];

                        // Ensure parentNode.children is initialized
                        if (parentNode.children == null)
                        {
                            parentNode.children = new List<dynamic>();
                        }

                        var parentOptionNode = ((List<dynamic>)parentNode.children)
                            .FirstOrDefault(o => o.key == $"o_{parentOptionId.Value}");

                        if (parentOptionNode != null)
                        {
                            // Ensure parentOptionNode.children is initialized
                            if (parentOptionNode.children == null)
                            {
                                parentOptionNode.children = new List<dynamic>();
                            }

                            parentOptionNode.children.Add(questionNode);
                        }
                    }
                }


                // Convert to JSON
                return Newtonsoft.Json.JsonConvert.SerializeObject(treeData, Newtonsoft.Json.Formatting.None,
                    new Newtonsoft.Json.JsonSerializerSettings
                    {
                        ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                    });
            }
            catch (Exception ex)
            {
                return $"error: {ex.Message}";
            }
        }


        [WebMethod]
        public static string DeleteQuestionNode(int questionTreeId)
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                // Create parameters
                SqlParameter pQuestionTreeId = new SqlParameter("@questionTreeId", questionTreeId);
                SqlParameter pDeletedBy = new SqlParameter("@deletedBy", HttpContext.Current.Session["userName"]);
                SqlParameter pDeletedDate = new SqlParameter("@deletedDate", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                // Execute stored procedure
                int rowsAffected = db.ExecuteStoredProcedure("sp_DeleteQuestionTreeTest",
                    pQuestionTreeId,
                    pDeletedBy,
                    pDeletedDate);

                // Return a response based on the result
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
                return $"error: {ex.Message}";
            }
        }



        [WebMethod]
        public static string GetQuestionTreeDataOld()
        {
            try
            {
                Utility.DatabaseHelper db = new Utility.DatabaseHelper();

                // Load questions and build tree
                string questionQuery = @"exec sp_get_ramificationTest";

                DataTable questionTable = db.ExecuteQuery(questionQuery);

                // Load options
                string optionQuery = @"
            SELECT 
                o.optionId,
                o.optionName,
                o.questionId
            FROM 
                tbl_options o
            WHERE 
                o.isActive = 1;";
                DataTable optionTable = db.ExecuteQuery(optionQuery);

                // Create dictionaries for easier lookup
                Dictionary<int, dynamic> nodes = new Dictionary<int, dynamic>();
                List<dynamic> treeData = new List<dynamic>();

                // Create the static "Ramification" node
                var ramificationNode = new
                {
                    title = "Ramification",
                    key = "root_0",
                    folder = true,
                    expanded = true,
                    children = new List<dynamic>()
                };
                treeData.Add(ramificationNode);

                // Create option dictionary for lookup
                Dictionary<int, List<dynamic>> optionNodes = new Dictionary<int, List<dynamic>>();
                foreach (DataRow row in optionTable.Rows)
                {
                    int questionId = row.Field<int>("questionId");
                    int optionId = row.Field<int>("optionId");
                    string optionName = row.Field<string>("optionName");

                    var optionNode = new
                    {
                        title = optionName,
                        key = $"o_{optionId}",
                        folder = false,
                        isOption = true,
                        optionId = optionId, // Add optionId for reference
                        questionId = questionId, // Add questionId for reference
                        children = new List<dynamic>()
                    };

                    if (!optionNodes.ContainsKey(questionId))
                    {
                        optionNodes[questionId] = new List<dynamic>();
                    }
                    optionNodes[questionId].Add(optionNode);
                }

                // Iterate over the question data and build the tree structure
                foreach (DataRow questionRow in questionTable.Rows)
                {
                    int questionTreeId = questionRow.Field<int>("questionTreeId"); // Ensure questionTreeId is retrieved
                    int questionId = questionRow.Field<int>("questionId");
                    int? parentOptionId = questionRow.Field<int?>("parentOptionId");
                    int? parentQuestionId = questionRow.Field<int?>("parentQuestionId");
                    string questionTitle = questionRow.Field<string>("questionTitle");

                    var questionNode = new
                    {
                        title = questionTitle,
                        key = $"q_{questionId}",
                        folder = true,
                        isOption = false,
                        questionId = questionId, // Add questionId for reference
                        questionTreeId = questionTreeId, // Add questionTreeId for reference
                        parentOptionId = parentOptionId, // Add parentOptionId for reference
                        parentQuestionId = parentQuestionId, // Add parentQuestionId for reference
                        children = new List<dynamic>()
                    };

                    nodes[questionId] = questionNode;

                    // Add options under the question if available
                    if (optionNodes.ContainsKey(questionId))
                    {
                        foreach (var optionNode in optionNodes[questionId])
                        {
                            questionNode.children.Add(optionNode);
                        }
                    }

                    if (parentQuestionId == null && parentOptionId == null)
                    {
                        // This is a root-level question, add it to the "Ramification" node
                        ramificationNode.children.Add(questionNode);
                    }
                    else if (parentOptionId != null && nodes.ContainsKey(parentQuestionId.Value))
                    {
                        // Add question as a child of the parent option
                        var parentNode = nodes[parentQuestionId.Value];

                        // Ensure parentNode.children is initialized
                        if (parentNode.children == null)
                        {
                            parentNode.children = new List<dynamic>();
                        }

                        var parentOptionNode = ((List<dynamic>)parentNode.children)
                            .FirstOrDefault(o => o.key == $"o_{parentOptionId.Value}");

                        if (parentOptionNode != null)
                        {
                            // Ensure parentOptionNode.children is initialized
                            if (parentOptionNode.children == null)
                            {
                                parentOptionNode.children = new List<dynamic>();
                            }

                            parentOptionNode.children.Add(questionNode);
                        }
                    }
                }


                // Convert to JSON
                return Newtonsoft.Json.JsonConvert.SerializeObject(treeData, Newtonsoft.Json.Formatting.None,
                    new Newtonsoft.Json.JsonSerializerSettings
                    {
                        ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore
                    });
            }
            catch (Exception ex)
            {
                return $"error: {ex.Message}";
            }
        }
    }
}

public class QuestionTreeTable
{
    public int questionTreeId { get; set; }
    public int nodeLevel { get; set; }
    public int fatherQuestionTreeId { get; set; }
    public int optionId { get; set; }
    public int questionId { get; set; }
    public int parentOptionId { get; set; }
    public int parentQuestionId { get; set; }
    public int startingQuestionTreeId { get; set; }
    public int isActive { get; set; }
}

public class OptionTable
{
    public int optionID { get; set; }
    public string optionName { get; set; }
    public int questionId { get; set; }
    public int isActive { get; set; }

    //extra field for treeStructure support
    public QuestionTable children { get; set; }
    public QuestionTreeTable treeNodeElement { get; set; }
    public string title => optionName;
    public string key => Guid.NewGuid().ToString().Substring(0, 8);

    public bool isOption = true, folder = false;
}

public class QuestionTable
{
    public int questionId { get; set; }
    public int catId { get; set; }
    public int subCatId { get; set; }
    public string questionName { get; set; }
    public int quesType { get; set; }
    public int isActive { get; set; }

    //extra field for treeStructure support
    public List<OptionTable> children { get; set; }
    public QuestionTreeTable treeNodeElement { get; set; }
    public string title => questionName;
    public string key => Guid.NewGuid().ToString().Substring(0,8);

    public bool isOption = false, folder = true;
}