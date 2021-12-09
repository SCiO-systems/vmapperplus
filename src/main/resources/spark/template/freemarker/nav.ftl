<nav class="navbar navbar-default navbar-fixed-top navbar-inverse">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navBar">
              <span class="glyphicon glyphicon-menu-hamburger"></span>
            </button>
            <a class="navbar-brand navbar-static-top">VMapper+</a>
        </div>
        <div class="collapse navbar-collapse" id="navBar">
            <ul class="nav navbar-nav">

                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-briefcase"></span> Data Tools <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="${env_path_web_tools.getVMAPPER()}"><span class="glyphicon glyphicon-road"></span> VMapper+</a></li>
                    </ul>
                </li>
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-question-sign"></span> Help <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#" onClick="window.open('https://github.com/SCiO-systems/vmapperplus/issues')"><span class="glyphicon glyphicon-pencil"></span> Report Issues</a></li>
                        <li><a href="#" onClick="alertBox('VMapper+ is an annotation service for tabular data that allows the association of each data column with entities defined in controlled knowledge organization systems (KOS). For more information visit the <a target=\'_blank\' href=\'https://github.com/SCiO-systems/vmapperplus\'>VMapper+ public GitHub</a>')"><span class="glyphicon glyphicon-info-sign"></span> About VMapper</a></li>
                    </ul>
                </li>
            </ul>
            <ul class="nav navbar-nav navbar-right">
                <#if currentUser?? >
                <li class="active navbar-left">
                    <a>Hello, ${currentUser}</a>
                </li>
                <li class="navbar-defalut">
                    <a href="/logout"><span class="glyphicon glyphicon-log-out"></span> Logout&nbsp;&nbsp;&nbsp;&nbsp;</a>
                </li>
                <#else>
                </#if>
            </ul>
        </div>
    </div><!-- /container -->
</nav><!-- /navbar wrapper -->