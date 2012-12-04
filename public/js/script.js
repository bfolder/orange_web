$(function() {
    $("#task-block").sortable({
        opacity: 0.5,
        axis: "y",
        beforeStop: function(event, ui){
            var id = ui.item.attr('id');
            var newIndex = ui.item.index();
            $.ajax({
               type: "PUT",
               url: id,
               data: {position: newIndex + 1}
            });
        }
    });

    $(".checkbox").click(function(){
        var isDone = "off";
        var id = $("this").parentNode.parentNode.id;
        $.ajax({
            type: "PUT",
            url: id,
            data: {done: isDone}
        });
    });
    $("#task-block").disableSelection();
});