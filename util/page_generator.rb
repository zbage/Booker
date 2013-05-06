if !$LOAD_PATH.include?(File.dirname(File.realpath(__FILE__)))
	$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__))) 
end

require 'sqlitehelper'
SqliteHelper.db_name = '../database/booker.db'
require '../web/models'

def generate_creation_page entity, action, title
	
	js = %Q{<script type="text/javascript">

	function verify_and_submit(form)
	\{
		var alert_msg = '';
	}
	html = %Q{<div style="width: 400px;margin:auto;margin-top:200px">
	
	<form action="/#{action}" method="post">
		
		<table width="300px">
			<tr>
				<th colspan=2 align='center'>#{title}</th>
			</tr>
		}

	entity.instance_methods(false).each do |m|
		if m != :insert and m != :update and m != :id and m.to_s !~ /=$/
			js = js + %Q{var #{m} = document.getElementById('#{m}').value;
		if(#{m}=='')
		{
			alert_msg = alert_msg + "#{(m.to_s.split('_').map &:capitalize).join(' ')} can not be empty!\\n";
		}
			}
			html = html + %Q{			<tr>
				<td style="padding-left:5px;width:100px">#{(m.to_s.split('_').map &:capitalize).join(' ')}</td>
				<td><input type="text" name="#{m}" id="#{m}"/></td>
			</tr>
		}
		end
	end
	js = js + %q{		if(alert_msg!='')
			alert(alert_msg);
		else
			form.submit();
	\}

</script>}
	html = html + %q{<tr>
				<td colspan=2 align='right'><input value="Create" type="button" class="button" onclick="javascript:verify_and_submit(this.form);"></td>
			</tr>
		</table>
		
	</form>

</div>}
	File.open(action + '.erb', 'w') {|f| f.puts js; f.puts html}
end

entity = Menu
action = 'createmenu'
title = 'Create New Menu'
generate_creation_page entity, action, title