$(function() {
    $("#task-block").sortable({
        opacity: 0.5,
        axis: "y",
        beforeStop: function(event, ui){
            var id = ui.item.attr('id');
            var newIndex = ui.item.index();
            $.ajax({
               type: "PUT",
               url: "/tasks/" + id,
               data: {position: newIndex + 1}
            });
        }
    });

    $(".clear-checked").click(function(){
        $(".checked").hide(150, function(){
            $.ajax({
                type: "GET",
                url: "/tasks/clear"
            });
        });
    });

    $(".remover").click(function(){
        $(this).parent().hide(150, function(){
            var id = $(this).attr('id');
            $.ajax({
                type: "DELETE",
                url: "/tasks/" + id
            });
        });
    });

    $(".checkbox").click(function(){
        var isDone = "on";
        var id = this.parentNode.id;

        if($(this).hasClass("checkedbox"))
        {
            isDone = "off";
            $(this).removeClass("checkedbox");
            $(this).parent().removeClass("checked")
            $(this).parent().fadeTo(250, 1.0);
        }
        else
        {
            $(this).addClass("checkedbox");
            $(this).parent().addClass("checked")
            $(this).parent().fadeTo(250, 0.25);
        }

        $.ajax({
            type: "PUT",
            url: "/tasks/" + id,
            data: {done: isDone}
        });

    });
    $("#task-block").disableSelection();
});