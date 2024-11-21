    function showAlert(message, alertType) {
        // Determine alert color and icon based on alert type
        var alertClass = "";
    var iconClass = "";
        if (alertType === "success") {
        alertClass = "alert-success";
    iconClass = "ri-check-line";
        } else if (alertType === "danger") {
        alertClass = "alert-danger";
    iconClass = "ri-close-circle-line";
        }
        else if (alertType === "update") {
            alertClass = "alert-warning";
            iconClass = "ri-alert-line";
        }
        else if (alertType === "delete") {
            alertClass = "alert-info";
            iconClass = "ri-information-line";
        }

// Display alert message using Bootstrap alert
var alertHtml = `
            <div class="alert ${alertClass} alert-dismissible fade show" role="alert">
        <i class="${iconClass} me-2"></i>
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>`;

// Append alert HTML to body
        $('#msgAlert').html(alertHtml);
}

