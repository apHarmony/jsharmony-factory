/* check_scope_id */
create function check_scope_id(
	@in_scope nvarchar(32),
  @in_scope_id bigint,
	@in_cust_id bigint
)
returns bigint 
as
begin
  declare @rslt bigint;

  set @rslt = null;

  if (@in_cust_id is null)
  begin
    if (@in_scope='C') select @rslt = cust_id from cust where cust_id=@in_scope_id;
    if (@in_scope='U') select @rslt = sys_user_id from jsharmony.sys_user where sys_user_id=@in_scope_id;
    if (@in_scope='S') select @rslt = 1;
  end
  else
  begin
    if (@in_scope='C')
    begin
      if (isnull(dbo.get_cust_id('cust', @in_scope_id),0) = @in_cust_id) select @rslt = @in_cust_id;
    end
  end

  return(@rslt);
end
go
grant execute on check_scope_id to jsharmony_role_exec;
go
grant execute on check_scope_id TO jsharmony_role_dev;
go

/* get_cust_id */
create function get_cust_id(
	@in_tabn nvarchar(32),
	@in_tabid bigint
)
returns bigint 
as
begin
  declare @rslt bigint;
  declare @next_tabn nvarchar(32);
  declare @next_tabid bigint;

  set @rslt = null;

  if (@in_tabn='cust')
  begin
    select @rslt=cust_id from cust where cust_id = @in_tabid;
    return(@in_tabid);
  end

  if (@in_tabn='cust_user')
  begin
    select @rslt=cust_id from jsharmony.cust_user where sys_user_id = @in_tabid;
    return(@rslt);
  end

  if (@in_tabn='cust_user_role')
  begin
    select @rslt=cust_id from jsharmony.cust_user_role inner join jsharmony.cust_user on jsharmony.cust_user.sys_user_id = jsharmony.cust_user_role.sys_user_id where cust_user_role_id = @in_tabid;
    return(@rslt);
  end

  if (@in_tabn='doc')
  begin
    select @next_tabn=isnull(code_code, code_val),  @next_tabid=doc_scope_id from jsharmony.code_doc_scope inner join jsharmony.doc on doc.doc_scope = code_doc_scope.code_val where doc_id = @in_tabid;
    return(dbo.get_cust_id(@next_tabn, @next_tabid));
  end

  if (@in_tabn='note')
  begin
    select @next_tabn=isnull(code_code, code_val),  @next_tabid=note_scope_id from jsharmony.code_note_scope inner join jsharmony.note on note.note_scope = code_note_scope.code_val where note_id = @in_tabid;
    return(dbo.get_cust_id(@next_tabn, @next_tabid));
  end

  return(null);
end
go
grant execute on get_cust_id to jsharmony_role_exec;
go
grant execute on get_cust_id TO jsharmony_role_dev;
go

/* get_item_id */
create function get_item_id(
	@in_tabn nvarchar(32),
	@in_tabid bigint
)
returns bigint 
as
begin
  declare @rslt bigint;
  declare @next_tabn nvarchar(32);
  declare @next_tabid bigint;

  set @rslt = null;

  if (@in_tabn='doc')
  begin
    select @next_tabn=isnull(code_code, code_val),  @next_tabid=doc_scope_id from jsharmony.code_doc_scope inner join jsharmony.doc on doc.doc_scope = code_doc_scope.code_val where doc_id = @in_tabid;
    return(dbo.get_item_id(@next_tabn, @next_tabid));
  end

  if (@in_tabn='note')
  begin
    select @next_tabn=isnull(code_code, code_val),  @next_tabid=note_scope_id from jsharmony.code_note_scope inner join jsharmony.note on note.note_scope = code_note_scope.code_val where note_id = @in_tabid;
    return(dbo.get_item_id(@next_tabn, @next_tabid));
  end

  return(null);
end
go
grant execute on get_item_id to jsharmony_role_exec;
go
grant execute on get_item_id TO jsharmony_role_dev;
go

/* Update param reference */
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'check_scope_id', 'dbo.check_scope_id');
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'get_cust_id', 'dbo.get_cust_id');
insert into jsharmony.param_sys (param_sys_process, param_sys_attrib, param_sys_val) VALUES ('SQL', 'get_item_id', 'dbo.get_item_id');
go
