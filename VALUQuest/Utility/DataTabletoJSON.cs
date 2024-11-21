using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace VALUQuest.Utility
{
    public class DataTabletoJSON
    {

        public string DataTableToJSON(DataTable table)
        {
            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            System.Collections.ArrayList rows = new System.Collections.ArrayList();
            System.Collections.Generic.Dictionary<string, object> row;

            foreach (DataRow dr in table.Rows)
            {
                row = new System.Collections.Generic.Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    row.Add(col.ColumnName, dr[col]);
                }
                rows.Add(row);
            }
            return serializer.Serialize(rows);
        }
    }
}