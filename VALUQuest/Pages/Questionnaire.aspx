<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="Questionnaire.aspx.cs" Inherits="VALUQuest.Pages.Questionnaire" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">


    <div class="row">
        <div class="col-12">
            <div class="page-title-box">
                <h4 class="page-title">Tree Ques</h4>
            </div>
        </div>
    </div>

    <div id="msgAlert"></div>
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div id="questionContainer" runat="server">
                                <!-- Placeholder for questions and options -->
                                <asp:Label ID="lblQuestion" runat="server" Text=""></asp:Label>
                                <asp:RadioButtonList ID="rblOptions" runat="server" AutoPostBack="true" OnSelectedIndexChanged="rblOptions_SelectedIndexChanged"></asp:RadioButtonList>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
