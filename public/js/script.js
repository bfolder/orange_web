$(function() {
    $("#task-block").sortable({
        opacity: 0.75,
        axis: "y",
        stop: function(event, ui){

        }
    });
    $("#task-block").disableSelection();
});