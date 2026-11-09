namespace System.Security.AccessControl;

using System.Environment;

report 8314 "Effective Permissions Overview"
{
    ApplicationArea = All;
    Caption = 'Effective Permissions Overview (Excel)';
    DefaultRenderingLayout = ExcelLayout;
    UsageCategory = ReportsAndAnalysis;
    AllowScheduling = true;

    dataset
    {
        dataitem(EffectivePermission; "Effective Permission Buffer")
        {
            RequestFilterFields = "User Name", "Object Type", "Object ID", "Read Permission", "Insert Permission", "Modify Permission",
                                    "Delete Permission", "Execute Permission";

            column(Company; Company)
            {
                IncludeCaption = true;
            }
            column(UserName; "User Name")
            {
                IncludeCaption = true;
            }
            column(ObjectType; "Object Type")
            {
                IncludeCaption = true;
            }
            column(ObjectID; "Object ID")
            {
                IncludeCaption = true;
            }
            column(ObjectName; "Object Name")
            {
                IncludeCaption = true;
            }
            column(ReadPermission; "Read Permission")
            {
                IncludeCaption = true;
            }
            column(InsertPermission; "Insert Permission")
            {
                IncludeCaption = true;
            }
            column(ModifyPermission; "Modify Permission")
            {
                IncludeCaption = true;
            }
            column(DeletePermission; "Delete Permission")
            {
                IncludeCaption = true;
            }
            column(ExecutePermission; "Execute Permission")
            {
                IncludeCaption = true;
            }

            trigger OnPreDataItem()
            var
                ObjTypeFilter: Option " ","Table Data","Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query",System;
            begin
                if EffectivePermission.GetFilter("Object Type") <> '' then
                    ObjTypeFilter := EffectivePermission."Object Type";

                EffectivePermissionsMgt.LoadData(EffectivePermission, TempUser, EffectivePermission.GetFilter("User Name"), ObjTypeFilter, EffectivePermission.GetFilter("Object ID"), CompanyFilter);
            end;
        }
    }

    requestpage
    {
        AboutTitle = 'About Effective Permissions Overview';
        AboutText = 'Audit the effective permissions each user has across objects in your system, as well as which assigned permission set contributed to each effective permission. Effective permissions show the final access to objects and data, helping you verify access and troubleshoot permission issues.';
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(RequestCompanyFilter; CompanyFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Company';
                        TableRelation = Company;
                        ToolTip = 'Specifies the company for which effective permissions will be calculated.';
                    }
                    // Used to set a report header across multiple languages
                    field(RequestEffectivePermissionsFilterHeading; EffectivePermissionsFilterHeading)
                    {
                        ApplicationArea = All;
                        Caption = 'Effective Permissions Filter';
                        ToolTip = 'Specifies the effective permissions filters applied to this report.';
                        Visible = false;
                    }
                    field(RequestCompanyFilterHeading; CompanyFilterHeading)
                    {
                        ApplicationArea = All;
                        Caption = 'Company Filter';
                        ToolTip = 'Specifies the company filter applied to this report.';
                        Visible = false;
                    }
                }
            }
        }

        trigger OnClosePage()
        begin
            UpdateRequestPageFilterValues();
        end;
    }

    rendering
    {
        layout(ExcelLayout)
        {
            Caption = 'Effective Permissions Overview Excel';
            Type = Excel;
            LayoutFile = './Inventory/Reports/EffectivePermissionsOverview.xlsx';
            Summary = 'Built in layout for the Effective Permissions Overview Excel report.';
        }
    }

    labels
    {
        EffectPermOverviewLbl = 'Effective Permissions Overview';
        EffectPermsOverviewPrintLbl = 'Effective Perms. (Print)', MaxLength = 31, Comment = 'Excel worksheet name.';
        EffectPermOverviewAnalysisLbl = 'Effective Perms. (Analysis)', MaxLength = 31, Comment = 'Excel worksheet name.';
        DataRetrievedLbl = 'Data retrieved:';
        // About the report labels
        AboutTheReportLbl = 'About the report';
        EnvironmentLbl = 'Environment';
        CompanyLbl = 'Company';
        UserLbl = 'User';
        RunOnLbl = 'Run on';
        ReportNameLbl = 'Report name';
        DocumentationLbl = 'Documentation';
    }

    var
        TempUser: Record User temporary;
        EffectivePermissionsMgt: Codeunit "Effective Permissions Mgt.";
        CompanyFilter: Text[30];
        EffectivePermissionsFilter: Text;
        EffectivePermissionsFilterHeading: Text;
        CompanyFilterHeading: Text;

    trigger OnInitReport()
    begin
        CompanyFilter := CopyStr(CompanyName(), 1, MaxStrLen(CompanyFilter));
    end;

    trigger OnPreReport()
    begin
        EffectivePermissionsMgt.DisallowViewingEffectivePermissionsForNonAdminUsers(UserSecurityId());

        UpdateRequestPageFilterValues();
    end;

    procedure SetCompanyFilter(NewCompanyFilter: Text[30])
    begin
        CompanyFilter := NewCompanyFilter;
    end;

    // Ensures Layout Filter Headings are up to date
    local procedure UpdateRequestPageFilterValues()
    var
        FilterHeadingLbl: Label '%1: %2', Comment = '%1 = Table/Field Caption, %2 = Filter Value';
    begin
        EffectivePermissionsFilter := EffectivePermission.GetFilters();
        if EffectivePermissionsFilter <> '' then
            EffectivePermissionsFilterHeading := StrSubstNo(FilterHeadingLbl, EffectivePermission.TableCaption, EffectivePermissionsFilter)
        else
            EffectivePermissionsFilterHeading := '';
        if CompanyFilter <> '' then
            CompanyFilterHeading := StrSubstNo(FilterHeadingLbl, EffectivePermission.FieldCaption(Company), CompanyFilter);
    end;
}