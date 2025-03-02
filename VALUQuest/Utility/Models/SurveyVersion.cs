using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace VALUQuest.Utility.Models
{
    public class SurveyVersion
    {
        public int idSurvey_Version { get; set; }
        public string code { get; set; }
        public string description { get; set; }
        public string webAppConnectionStringName { get; set; }
        public string databaseName { get; set; }
        public string mobileAppConnectionName { get; set; }
        public bool deleted { get; set; }
        public bool isDefault { get; set; }
    }
}