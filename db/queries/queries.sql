-- name: BuildCreate :one
insert into unweave.build (project_id, builder_type, name, created_by, started_at)
values ($1, $2, $3, $4, case
                            when @started_at::timestamptz = '0001-01-01 00:00:00 UTC'::timestamptz
                                then now()
                            else @started_at::timestamptz end)
returning id;


-- name: BuildGet :one
select *
from unweave.build
where id = $1;

-- name: BuildGetUsedBy :many
select s.*, n.provider
from (select id from unweave.build as ub where ub.id = $1) as b
         join unweave.exec s
              on s.build_id = b.id
         join unweave.node as n on s.node_id = n.id;

-- name: BuildUpdate :exec
update unweave.build
set status      = $2,
    meta_data   = $3,
    started_at  = coalesce(
            nullif(@started_at::timestamptz, '0001-01-01 00:00:00 UTC'::timestamptz),
            started_at),
    finished_at = coalesce(
            nullif(@finished_at::timestamptz, '0001-01-01 00:00:00 UTC'::timestamptz),
            finished_at)
where id = $1;


-- name: ProjectGet :one
select *
from unweave.project
where id = $1;

-- name: NodeCreate :exec
select unweave.insert_node(
               @id,
               @provider,
               @region,
               @metadata :: jsonb,
               @status,
               @owner_id,
               @ssh_key_ids :: text[]
           );

-- name: NodeStatusUpdate :exec
update unweave.node
set status        = $2,
    ready_at      = coalesce(sqlc.narg('ready_at'), ready_at),
    terminated_at = coalesce(sqlc.narg('terminated_at'), terminated_at)
where id = $1;


-- name: SSHKeyAdd :exec
insert into unweave.ssh_key (owner_id, name, public_key)
values ($1, $2, $3);

-- name: SSHKeysGet :many
select *
from unweave.ssh_key
where owner_id = $1;

-- name: SSHKeyGetByName :one
select *
from unweave.ssh_key
where name = $1
  and owner_id = $2;

-- name: SSHKeyGetByPublicKey :one
select *
from unweave.ssh_key
where public_key = $1
  and owner_id = $2;


-------------------------------------------------------------------
-- The queries below return data in the format expected by the API.
-------------------------------------------------------------------

-- name: MxExecGet :one
select e.id,
       e.name,
       e.status,
       e.provider,
       e.region,
       e.created_at,
       e.metadata
from unweave.exec as e
where e.id = $1;

-- name: MxExecsGet :many
select e.id,
       e.name,
       e.status,
       e.provider,
       e.region,
       e.created_at,
       e.metadata
from unweave.exec as e
where e.project_id = $1;