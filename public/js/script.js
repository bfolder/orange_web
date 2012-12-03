$(function() {
    $("#task-block").sortable({
        opacity: 0.5,
        axis: "y",
        beforeStop: function(event, ui){
            var id = ui.item.attr('id')
            var newIndex = ui.item.index();
            $.ajax({
               type: "PUT",
               url: id,
               data: {position: newIndex + 1}
            });
        }
    });
    $("#task-block").disableSelection();
});