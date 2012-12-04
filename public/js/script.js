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

    $(".clear-checked").click(function(){
        $(".checked").slideUp().fadeOut(function(){
            $.ajax({
                type: "GET",
                url: "clear/"
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
            url: id,
            data: {done: isDone}
        });

    });
    $("#task-block").disableSelection();
});