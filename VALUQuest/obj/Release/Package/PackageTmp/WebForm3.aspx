<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>DataTables Row Grouping</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- DataTables CSS -->
    <link href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/responsive/2.2.9/css/responsive.bootstrap5.min.css" rel="stylesheet">
    <!-- Font Awesome for Plus/Minus Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <table id="example" class="table table-striped table-bordered dt-responsive nowrap" style="width:100%">
            <thead>
                <tr>
                    <th>Group</th>
                    <th>Name</th>
                    <th>Position</th>
                    <th>Office</th>
                    <th>Age</th>
                    <th>Start date</th>
                    <th>Salary</th>
                    <th style="display:none;">Group Search</th> <!-- Hidden column for group search -->
                </tr>
            </thead>
            <tbody>
                <tr data-group="Group 1">
                    <td>Group 1</td>
                    <td>Tiger Nixon</td>
                    <td>System Architect</td>
                    <td>Edinburgh</td>
                    <td>61</td>
                    <td>2011/04/25</td>
                    <td>$320,800</td>
                    <td style="display:none;">Group 1</td> <!-- Hidden column for group search -->
                </tr>
                <tr data-group="Group 1">
                    <td>Group 1</td>
                    <td>Garrett Winters</td>
                    <td>Accountant</td>
                    <td>Tokyo</td>
                    <td>63</td>
                    <td>2011/07/25</td>
                    <td>$170,750</td>
                    <td style="display:none;">Group 1</td> <!-- Hidden column for group search -->
                </tr>
                <tr data-group="Group 2">
                    <td>Group 2</td>
                    <td>Ashton Cox</td>
                    <td>Junior Technical Author</td>
                    <td>San Francisco</td>
                    <td>66</td>
                    <td>2009/01/12</td>
                    <td>$86,000</td>
                    <td style="display:none;">Group 2</td> <!-- Hidden column for group search -->
                </tr>
                <tr data-group="Group 2">
                    <td>Group 2</td>
                    <td>Cedric Kelly</td>
                    <td>Senior Javascript Developer</td>
                    <td>Edinburgh</td>
                    <td>22</td>
                    <td>2012/03/29</td>
                    <td>$433,060</td>
                    <td style="display:none;">Group 2</td> <!-- Hidden column for group search -->
                </tr>
            </tbody>
        </table>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.9/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.2.9/js/responsive.bootstrap5.min.js"></script>

    <script>
        $(document).ready(function() {
            var table = $('#example').DataTable({
                "order": [[0, 'asc']],
                "displayLength": 25,
                "columnDefs": [
                    { "visible": false, "targets": 7 } // Hide the Group Search column
                ],
                "drawCallback": function(settings) {
                    var api = this.api();
                    var rows = api.rows({ page: 'current' }).nodes();
                    var last = null;
                    var groupColumn = 0; // Column index for the group

                    api.column(groupColumn, { page: 'current' }).data().each(function(group, i) {
                        if (last !== group) {
                            $(rows).eq(i).before(
                                '<tr class="group"><td colspan="7"><i class="fas fa-plus-circle"></i> ' + group + '</td></tr>'
                            );
                            last = group;
                        }
                    });
                }
            });

            // Add event listener for opening and closing details
            $('#example tbody').on('click', 'tr.group', function() {
                var icon = $(this).find('i');
                icon.toggleClass('fa-plus-circle fa-minus-circle');
                var group = $(this).nextUntil('.group');
                group.toggle();
            });

            // Initially hide grouped rows
            $('#example tbody tr.group').nextUntil('.group').hide();
        });
    </script>
</body>
</html>
