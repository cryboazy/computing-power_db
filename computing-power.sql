-- public.collect_info definition

-- Drop table

-- DROP TABLE collect_info;

CREATE TABLE collect_info (
	id bigserial NOT NULL, -- 采集信息ID
	task_id int8 NULL, -- 任务ID
	task_name varchar(100) DEFAULT NULL::character varying NULL, -- 任务名称
	organization_id int8 NULL, -- 组织ID
	organization_name varchar(100) DEFAULT NULL::character varying NULL, -- 组织名称
	device_id int8 NULL, -- 设备ID
	device_name varchar(100) DEFAULT NULL::character varying NULL, -- 设备名称
	baseboard_serial_number varchar(100) NOT NULL, -- 设备序列号
	collection_timestamp timestamp(0) NOT NULL, -- 采集时间
	cpu_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- CPU使用率(%)
	cpu_physical_cores int4 NULL, -- CPU物理核心数
	cpu_logical_cores int4 NULL, -- CPU逻辑核心数
	memory_total_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 总内存(GB)
	memory_used_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 已用内存(GB)
	memory_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 内存使用率(%)
	disk_total_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 总磁盘空间(GB)
	disk_used_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 已用磁盘空间(GB)
	disk_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 磁盘使用率(%)
	network_bytes_sent_gb numeric(15, 2) DEFAULT NULL::numeric NULL, -- 累计发送流量(GB)
	network_bytes_recv_gb numeric(15, 2) DEFAULT NULL::numeric NULL, -- 累计接收流量(GB)
	gpu_count int4 NULL, -- GPU数量
	gpu_memory_total_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- GPU总显存(GB)
	gpu_memory_used_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- GPU已用显存(GB)
	gpu_memory_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU显存使用率(%)
	gpu_avg_utilization_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU平均利用率(%)
	gpu_avg_temperature numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU平均温度(℃)
	gpu_total_power_watts numeric(10, 2) DEFAULT NULL::numeric NULL, -- GPU总功耗(W)
	created_at timestamp DEFAULT pg_systimestamp() NULL, -- 记录创建时间
	gpu_name varchar(100) NULL, -- GPU名称
	CONSTRAINT collect_info_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX collect_info_idx_collection_time ON collect_info USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX collect_info_idx_device_time ON collect_info USING btree (baseboard_serial_number, collection_timestamp) TABLESPACE pg_default;
CREATE INDEX collect_info_idx_organization ON collect_info USING btree (organization_id) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.collect_info.id IS '采集信息ID';
COMMENT ON COLUMN public.collect_info.task_id IS '任务ID';
COMMENT ON COLUMN public.collect_info.task_name IS '任务名称';
COMMENT ON COLUMN public.collect_info.organization_id IS '组织ID';
COMMENT ON COLUMN public.collect_info.organization_name IS '组织名称';
COMMENT ON COLUMN public.collect_info.device_id IS '设备ID';
COMMENT ON COLUMN public.collect_info.device_name IS '设备名称';
COMMENT ON COLUMN public.collect_info.baseboard_serial_number IS '设备序列号';
COMMENT ON COLUMN public.collect_info.collection_timestamp IS '采集时间';
COMMENT ON COLUMN public.collect_info.cpu_usage_percent IS 'CPU使用率(%)';
COMMENT ON COLUMN public.collect_info.cpu_physical_cores IS 'CPU物理核心数';
COMMENT ON COLUMN public.collect_info.cpu_logical_cores IS 'CPU逻辑核心数';
COMMENT ON COLUMN public.collect_info.memory_total_gb IS '总内存(GB)';
COMMENT ON COLUMN public.collect_info.memory_used_gb IS '已用内存(GB)';
COMMENT ON COLUMN public.collect_info.memory_usage_percent IS '内存使用率(%)';
COMMENT ON COLUMN public.collect_info.disk_total_gb IS '总磁盘空间(GB)';
COMMENT ON COLUMN public.collect_info.disk_used_gb IS '已用磁盘空间(GB)';
COMMENT ON COLUMN public.collect_info.disk_usage_percent IS '磁盘使用率(%)';
COMMENT ON COLUMN public.collect_info.network_bytes_sent_gb IS '累计发送流量(GB)';
COMMENT ON COLUMN public.collect_info.network_bytes_recv_gb IS '累计接收流量(GB)';
COMMENT ON COLUMN public.collect_info.gpu_count IS 'GPU数量';
COMMENT ON COLUMN public.collect_info.gpu_memory_total_gb IS 'GPU总显存(GB)';
COMMENT ON COLUMN public.collect_info.gpu_memory_used_gb IS 'GPU已用显存(GB)';
COMMENT ON COLUMN public.collect_info.gpu_memory_usage_percent IS 'GPU显存使用率(%)';
COMMENT ON COLUMN public.collect_info.gpu_avg_utilization_percent IS 'GPU平均利用率(%)';
COMMENT ON COLUMN public.collect_info.gpu_avg_temperature IS 'GPU平均温度(℃)';
COMMENT ON COLUMN public.collect_info.gpu_total_power_watts IS 'GPU总功耗(W)';
COMMENT ON COLUMN public.collect_info.created_at IS '记录创建时间';
COMMENT ON COLUMN public.collect_info.gpu_name IS 'GPU名称';


-- public.collect_task definition

-- Drop table

-- DROP TABLE collect_task;

CREATE TABLE collect_task (
	id bigserial NOT NULL, -- 任务ID
	task_name varchar(100) NOT NULL, -- 任务名称
	description varchar(500) DEFAULT NULL::character varying NULL, -- 任务描述
	task_type varchar(50) DEFAULT NULL::character varying NULL, -- 任务类型
	target_id varchar(100) DEFAULT NULL::character varying NULL, -- 采集目标
	target_name varchar(100) DEFAULT NULL::character varying NULL, -- 目标名称
	metrics varchar(500) DEFAULT NULL::character varying NULL, -- 采集指标
	status int2 DEFAULT 0::smallint NULL, -- 任务状态: 0-待执行 1-执行中 2-成功 3-失败
	cron_expression varchar(100) DEFAULT NULL::character varying NULL, -- 执行频率(cron表达式)
	scheduled_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 计划执行时间
	start_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 实际开始时间
	end_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 实际结束时间
	duration int4 NULL, -- 执行时长(秒)
	data_count int4 NULL, -- 采集数据量
	"result" text NULL, -- 执行结果
	error_msg text NULL, -- 错误信息
	retry_count int4 DEFAULT 0 NULL, -- 重试次数
	max_retry_count int4 DEFAULT 3 NULL, -- 最大重试次数
	create_by varchar(50) DEFAULT NULL::character varying NULL, -- 创建人
	create_by_id int8 NULL, -- 创建人ID
	update_by varchar(50) DEFAULT NULL::character varying NULL, -- 更新人
	update_by_id int8 NULL, -- 更新人ID
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	"version" int4 DEFAULT 0 NULL, -- 版本号
	CONSTRAINT collect_task_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX collect_task_idx_create_time ON collect_task USING btree (create_time) TABLESPACE pg_default;
CREATE INDEX collect_task_idx_deleted ON collect_task USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX collect_task_idx_status ON collect_task USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.collect_task.id IS '任务ID';
COMMENT ON COLUMN public.collect_task.task_name IS '任务名称';
COMMENT ON COLUMN public.collect_task.description IS '任务描述';
COMMENT ON COLUMN public.collect_task.task_type IS '任务类型';
COMMENT ON COLUMN public.collect_task.target_id IS '采集目标';
COMMENT ON COLUMN public.collect_task.target_name IS '目标名称';
COMMENT ON COLUMN public.collect_task.metrics IS '采集指标';
COMMENT ON COLUMN public.collect_task.status IS '任务状态: 0-待执行 1-执行中 2-成功 3-失败';
COMMENT ON COLUMN public.collect_task.cron_expression IS '执行频率(cron表达式)';
COMMENT ON COLUMN public.collect_task.scheduled_time IS '计划执行时间';
COMMENT ON COLUMN public.collect_task.start_time IS '实际开始时间';
COMMENT ON COLUMN public.collect_task.end_time IS '实际结束时间';
COMMENT ON COLUMN public.collect_task.duration IS '执行时长(秒)';
COMMENT ON COLUMN public.collect_task.data_count IS '采集数据量';
COMMENT ON COLUMN public.collect_task."result" IS '执行结果';
COMMENT ON COLUMN public.collect_task.error_msg IS '错误信息';
COMMENT ON COLUMN public.collect_task.retry_count IS '重试次数';
COMMENT ON COLUMN public.collect_task.max_retry_count IS '最大重试次数';
COMMENT ON COLUMN public.collect_task.create_by IS '创建人';
COMMENT ON COLUMN public.collect_task.create_by_id IS '创建人ID';
COMMENT ON COLUMN public.collect_task.update_by IS '更新人';
COMMENT ON COLUMN public.collect_task.update_by_id IS '更新人ID';
COMMENT ON COLUMN public.collect_task.create_time IS '创建时间';
COMMENT ON COLUMN public.collect_task.update_time IS '更新时间';
COMMENT ON COLUMN public.collect_task.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.collect_task."version" IS '版本号';


-- public.collect_task_detail definition

-- Drop table

-- DROP TABLE collect_task_detail;

CREATE TABLE collect_task_detail (
	id bigserial NOT NULL,
	task_info_id int8 NOT NULL,
	detail_id varchar(50) NOT NULL,
	organization_id int8 NULL,
	organization_code varchar(50) DEFAULT NULL::character varying NULL,
	file_name varchar(255) DEFAULT NULL::character varying NULL,
	import_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL,
	status int2 DEFAULT 0::smallint NULL,
	remark text DEFAULT NULL::character varying NULL,
	record_count int4 DEFAULT 0 NULL,
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL,
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL,
	create_by varchar(50) DEFAULT NULL::character varying NULL,
	update_by varchar(50) DEFAULT NULL::character varying NULL,
	deleted int2 DEFAULT 0::smallint NULL,
	CONSTRAINT collect_task_detail_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX collect_task_detail_idx_collect_detail_id ON collect_task_detail USING btree (detail_id) TABLESPACE pg_default;
CREATE INDEX collect_task_detail_idx_collect_info_id ON collect_task_detail USING btree (task_info_id) TABLESPACE pg_default;
CREATE INDEX collect_task_detail_idx_deleted ON collect_task_detail USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX collect_task_detail_idx_import_time ON collect_task_detail USING btree (import_time) TABLESPACE pg_default;
CREATE INDEX collect_task_detail_idx_status ON collect_task_detail USING btree (status) TABLESPACE pg_default;


-- public.daily_device_summary definition

-- Drop table

-- DROP TABLE daily_device_summary;

CREATE TABLE daily_device_summary (
	id bigserial NOT NULL, -- 主键ID
	device_id int8 NOT NULL, -- 设备ID
	device_name varchar(255) NULL, -- 设备名称
	organization_id1 int8 NULL, -- 一级组织机构ID
	organization_name1 varchar(255) NULL, -- 一级组织机构名称
	organization_id2 int8 NULL, -- 二级组织机构ID
	organization_name2 varchar(255) NULL, -- 二级组织机构名称
	organization_id3 int8 NULL, -- 三级组织机构ID
	organization_name3 varchar(255) NULL, -- 三级组织机构名称
	province_code varchar(50) NULL, -- 省份编码
	province varchar(100) NULL, -- 省份名称
	avg_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU平均使用率(%)
	summary_date timestamp(0) NOT NULL, -- 汇总日期
	create_time timestamp DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp DEFAULT pg_systimestamp() NULL -- 更新时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX daily_device_summary_device_id_idx ON daily_device_summary USING btree (device_id, summary_date) TABLESPACE pg_default;
CREATE INDEX daily_device_summary_organization_id3_idx ON daily_device_summary USING btree (organization_id3) TABLESPACE pg_default;
CREATE INDEX daily_device_summary_province_code_idx ON daily_device_summary USING btree (province_code) TABLESPACE pg_default;
CREATE INDEX daily_device_summary_summary_date_idx ON daily_device_summary USING btree (summary_date) TABLESPACE pg_default;
COMMENT ON TABLE public.daily_device_summary IS '每日设备GPU使用率汇总表';

-- Column comments

COMMENT ON COLUMN public.daily_device_summary.id IS '主键ID';
COMMENT ON COLUMN public.daily_device_summary.device_id IS '设备ID';
COMMENT ON COLUMN public.daily_device_summary.device_name IS '设备名称';
COMMENT ON COLUMN public.daily_device_summary.organization_id1 IS '一级组织机构ID';
COMMENT ON COLUMN public.daily_device_summary.organization_name1 IS '一级组织机构名称';
COMMENT ON COLUMN public.daily_device_summary.organization_id2 IS '二级组织机构ID';
COMMENT ON COLUMN public.daily_device_summary.organization_name2 IS '二级组织机构名称';
COMMENT ON COLUMN public.daily_device_summary.organization_id3 IS '三级组织机构ID';
COMMENT ON COLUMN public.daily_device_summary.organization_name3 IS '三级组织机构名称';
COMMENT ON COLUMN public.daily_device_summary.province_code IS '省份编码';
COMMENT ON COLUMN public.daily_device_summary.province IS '省份名称';
COMMENT ON COLUMN public.daily_device_summary.avg_gpu_usage_rate IS 'GPU平均使用率(%)';
COMMENT ON COLUMN public.daily_device_summary.summary_date IS '汇总日期';
COMMENT ON COLUMN public.daily_device_summary.create_time IS '创建时间';
COMMENT ON COLUMN public.daily_device_summary.update_time IS '更新时间';


-- public.daily_gpu_usage_summary definition

-- Drop table

-- DROP TABLE daily_gpu_usage_summary;

CREATE TABLE daily_gpu_usage_summary (
	id bigserial NOT NULL, -- 主键ID
	summary_date timestamp(0) NOT NULL, -- 汇总日期
	total_device_count int4 DEFAULT 0 NULL, -- 设备总数
	total_gpu_count int4 DEFAULT 0 NULL, -- GPU总数
	avg_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU平均使用率(%)
	max_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU最大使用率(%)
	min_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU最小使用率(%)
	avg_memory_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 显存平均使用率(%)
	max_memory_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 显存最大使用率(%)
	min_memory_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 显存最小使用率(%)
	avg_temperature numeric(5, 2) DEFAULT 0.00 NULL, -- 平均温度(℃)
	max_temperature numeric(5, 2) DEFAULT 0.00 NULL, -- 最高温度(℃)
	memory_total_gb numeric(15, 2) DEFAULT NULL::numeric NULL, -- 显存总量(GB)
	compute_total_tflops numeric(15, 2) DEFAULT NULL::numeric NULL, -- 算力总量
	total_sample_count int8 DEFAULT 0::bigint NULL, -- 采样总数
	total_gpu_rate_sum int8 DEFAULT 0::bigint NULL, -- 当天采集gpu信息的和 用于汇总求平均
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	CONSTRAINT daily_gpu_usage_summary_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX daily_gpu_usage_summary_idx_summary_date ON daily_gpu_usage_summary USING btree (summary_date) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.daily_gpu_usage_summary.id IS '主键ID';
COMMENT ON COLUMN public.daily_gpu_usage_summary.summary_date IS '汇总日期';
COMMENT ON COLUMN public.daily_gpu_usage_summary.total_device_count IS '设备总数';
COMMENT ON COLUMN public.daily_gpu_usage_summary.total_gpu_count IS 'GPU总数';
COMMENT ON COLUMN public.daily_gpu_usage_summary.avg_gpu_usage_rate IS 'GPU平均使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.max_gpu_usage_rate IS 'GPU最大使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.min_gpu_usage_rate IS 'GPU最小使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.avg_memory_usage_rate IS '显存平均使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.max_memory_usage_rate IS '显存最大使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.min_memory_usage_rate IS '显存最小使用率(%)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.avg_temperature IS '平均温度(℃)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.max_temperature IS '最高温度(℃)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.memory_total_gb IS '显存总量(GB)';
COMMENT ON COLUMN public.daily_gpu_usage_summary.compute_total_tflops IS '算力总量';
COMMENT ON COLUMN public.daily_gpu_usage_summary.total_sample_count IS '采样总数';
COMMENT ON COLUMN public.daily_gpu_usage_summary.total_gpu_rate_sum IS '当天采集gpu信息的和 用于汇总求平均';
COMMENT ON COLUMN public.daily_gpu_usage_summary.create_time IS '创建时间';
COMMENT ON COLUMN public.daily_gpu_usage_summary.update_time IS '更新时间';


-- public.device definition

-- Drop table

-- DROP TABLE device;

CREATE TABLE device (
	id bigserial NOT NULL, -- 设备ID
	"name" varchar(100) NULL, -- 设备名称
	code varchar(50) NOT NULL -- 设备编码,--主板序列号
	organization_id int8 NULL, -- 所属组织机构ID
	organization_code varchar(50) DEFAULT NULL::character varying NULL, -- 组织编码
	cpu_cores int4 NULL, -- CPU核心数
	memory_size numeric(10, 2) DEFAULT NULL::numeric NULL, -- 内存大小(GB)
	disk_size numeric(10, 2) DEFAULT NULL::numeric NULL, -- 硬盘大小(GB)
	gpu_count int4 NULL, -- GPU数量
	gpu_model varchar(300) DEFAULT NULL::character varying NULL, -- GPU型号 关联 gpu_card_info的gpu_name
	total_memory numeric(10, 2) DEFAULT NULL::numeric NULL, -- 显存大小
	operating_system varchar(100) DEFAULT NULL::character varying NULL, -- 操作系统
	purpose int2 NULL, -- 设备用途: 1-训练 2-研发 3-推理
	net_module_code varchar(50) DEFAULT NULL::character varying NULL, -- 网络模块编码
	net_module_name varchar(50) DEFAULT NULL::character varying NULL, -- 网络模块名称
	detail_info text NULL, -- 设备明细json字符串
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by varchar(50) DEFAULT NULL::character varying NULL, -- 创建人
	update_by varchar(50) DEFAULT NULL::character varying NULL, -- 更新人
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	"version" int4 DEFAULT 0 NULL, -- 版本号
	online_status int4 NULL, -- 设备状态（0-离线，1-在线）
	CONSTRAINT device_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_code_idx ON device USING btree (code) TABLESPACE pg_default;
CREATE INDEX device_idx_deleted ON device USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX device_idx_organization_id ON device USING btree (organization_id) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device.id IS '设备ID';
COMMENT ON COLUMN public.device."name" IS '设备名称';
COMMENT ON COLUMN public.device.code IS '设备编码--主板序列号';
COMMENT ON COLUMN public.device.organization_id IS '所属组织机构ID';
COMMENT ON COLUMN public.device.organization_code IS '组织编码';
COMMENT ON COLUMN public.device.cpu_cores IS 'CPU核心数';
COMMENT ON COLUMN public.device.memory_size IS '内存大小(GB)';
COMMENT ON COLUMN public.device.disk_size IS '硬盘大小(GB)';
COMMENT ON COLUMN public.device.gpu_count IS 'GPU数量';
COMMENT ON COLUMN public.device.gpu_model IS 'GPU型号 关联 gpu_card_info的gpu_name';
COMMENT ON COLUMN public.device.total_memory IS '显存大小';
COMMENT ON COLUMN public.device.operating_system IS '操作系统';
COMMENT ON COLUMN public.device.purpose IS '设备用途: 1-训练 2-研发 3-推理';
COMMENT ON COLUMN public.device.net_module_code IS '网络模块编码';
COMMENT ON COLUMN public.device.net_module_name IS '网络模块名称';
COMMENT ON COLUMN public.device.detail_info IS '设备明细json字符串';
COMMENT ON COLUMN public.device.create_time IS '创建时间';
COMMENT ON COLUMN public.device.update_time IS '更新时间';
COMMENT ON COLUMN public.device.create_by IS '创建人';
COMMENT ON COLUMN public.device.update_by IS '更新人';
COMMENT ON COLUMN public.device.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.device."version" IS '版本号';
COMMENT ON COLUMN public.device.online_status IS '设备状态（0-离线，1-在线）';


-- public.device_bak definition

-- Drop table

-- DROP TABLE device_bak;

CREATE TABLE device_bak (
	id int8 NULL,
	"name" varchar(100) NULL,
	code varchar(50) NULL,
	organization_id int8 NULL,
	organization_code varchar(50) NULL,
	cpu_cores int4 NULL,
	memory_size numeric(10, 2) NULL,
	disk_size numeric(10, 2) NULL,
	gpu_count int4 NULL,
	gpu_model varchar(300) NULL,
	total_memory numeric(10, 2) NULL,
	operating_system varchar(100) NULL,
	purpose int2 NULL,
	net_module_code varchar(50) NULL,
	net_module_name varchar(50) NULL,
	detail_info text NULL,
	create_time timestamp(0) NULL,
	update_time timestamp(0) NULL,
	create_by varchar(50) NULL,
	update_by varchar(50) NULL,
	deleted int2 NULL,
	"version" int4 NULL,
	online_status int4 NULL
)
WITH (
	orientation=row,
	compression=no
);


-- public.device_cpu_monitor definition

-- Drop table

-- DROP TABLE device_cpu_monitor;

CREATE TABLE device_cpu_monitor (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 设备ID
	msg_id varchar(64) DEFAULT NULL::character varying NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) DEFAULT NULL::character varying NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) DEFAULT NULL::character varying NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织名称
	physical_cores int4 NULL, -- 物理核心数量
	logical_cores int4 NULL, -- 逻辑核心数量
	cpu_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 整体CPU使用率（百分比）
	load_average_1min numeric(5, 2) DEFAULT NULL::numeric NULL, -- 1分钟系统负载平均值
	load_average_5min numeric(5, 2) DEFAULT NULL::numeric NULL, -- 5分钟系统负载平均值
	load_average_15min numeric(5, 2) DEFAULT NULL::numeric NULL, -- 15分钟系统负载平均值
	user_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- 用户态CPU时间（秒）
	system_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- 系统态CPU时间（秒）
	idle_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- CPU空闲时间（秒）
	nice_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- 低优先级用户态CPU时间（秒）
	iowait_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- CPU等待IO时间（秒）
	irq_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- CPU处理硬中断时间（秒）
	softirq_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- CPU处理软中断时间（秒）
	steal_time numeric(10, 2) DEFAULT NULL::numeric NULL, -- 被虚拟机监控程序偷走的CPU时间（秒）
	user_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 用户态CPU使用率（百分比）
	system_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 系统态CPU使用率（百分比）
	idle_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- CPU空闲率（百分比）
	nice_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 低优先级用户态CPU使用率（百分比）
	iowait_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- CPU等待IO的百分比
	irq_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 硬中断占用CPU百分比
	softirq_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 软中断占用CPU百分比
	steal_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 被偷走的CPU时间百分比
	current_frequency numeric(10, 2) DEFAULT NULL::numeric NULL, -- 当前CPU频率（MHz）
	min_frequency numeric(10, 2) DEFAULT NULL::numeric NULL, -- 最小CPU频率（MHz）
	max_frequency numeric(10, 2) DEFAULT NULL::numeric NULL, -- 最大CPU频率（MHz）
	cumulative_ctx_switches int8 NULL, -- 累计上下文切换次数
	cumulative_interrupts int8 NULL, -- 累计中断次数
	cumulative_soft_interrupts int8 NULL, -- 累计软中断次数
	cumulative_syscalls int8 NULL, -- 累计系统调用次数
	ctx_switches_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒上下文切换次数
	interrupts_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒中断次数
	soft_interrupts_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒软中断次数
	syscalls_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒系统调用次数
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT device_cpu_monitor_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_cpu_monitor_idx_device_timestamp ON device_cpu_monitor USING btree (device_id, collection_timestamp) TABLESPACE pg_default;
CREATE INDEX device_idx_msg_id ON device_cpu_monitor USING btree (msg_id) TABLESPACE pg_default;
CREATE INDEX idx_cpu_collection ON device_cpu_monitor USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_cpu_device ON device_cpu_monitor USING btree (device_id) TABLESPACE pg_default;
CREATE INDEX idx_cpu_device_collection ON device_cpu_monitor USING btree (device_id, collection_timestamp DESC) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_cpu_monitor.id IS '自增主键';
COMMENT ON COLUMN public.device_cpu_monitor.device_id IS '设备ID';
COMMENT ON COLUMN public.device_cpu_monitor.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_cpu_monitor.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_cpu_monitor.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_cpu_monitor.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_cpu_monitor.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_cpu_monitor.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_cpu_monitor.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_cpu_monitor.physical_cores IS '物理核心数量';
COMMENT ON COLUMN public.device_cpu_monitor.logical_cores IS '逻辑核心数量';
COMMENT ON COLUMN public.device_cpu_monitor.cpu_percent IS '整体CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor.load_average_1min IS '1分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor.load_average_5min IS '5分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor.load_average_15min IS '15分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor.user_time IS '用户态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.system_time IS '系统态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.idle_time IS 'CPU空闲时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.nice_time IS '低优先级用户态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.iowait_time IS 'CPU等待IO时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.irq_time IS 'CPU处理硬中断时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.softirq_time IS 'CPU处理软中断时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.steal_time IS '被虚拟机监控程序偷走的CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor.user_percent IS '用户态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor.system_percent IS '系统态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor.idle_percent IS 'CPU空闲率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor.nice_percent IS '低优先级用户态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor.iowait_percent IS 'CPU等待IO的百分比';
COMMENT ON COLUMN public.device_cpu_monitor.irq_percent IS '硬中断占用CPU百分比';
COMMENT ON COLUMN public.device_cpu_monitor.softirq_percent IS '软中断占用CPU百分比';
COMMENT ON COLUMN public.device_cpu_monitor.steal_percent IS '被偷走的CPU时间百分比';
COMMENT ON COLUMN public.device_cpu_monitor.current_frequency IS '当前CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor.min_frequency IS '最小CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor.max_frequency IS '最大CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor.cumulative_ctx_switches IS '累计上下文切换次数';
COMMENT ON COLUMN public.device_cpu_monitor.cumulative_interrupts IS '累计中断次数';
COMMENT ON COLUMN public.device_cpu_monitor.cumulative_soft_interrupts IS '累计软中断次数';
COMMENT ON COLUMN public.device_cpu_monitor.cumulative_syscalls IS '累计系统调用次数';
COMMENT ON COLUMN public.device_cpu_monitor.ctx_switches_per_sec IS '每秒上下文切换次数';
COMMENT ON COLUMN public.device_cpu_monitor.interrupts_per_sec IS '每秒中断次数';
COMMENT ON COLUMN public.device_cpu_monitor.soft_interrupts_per_sec IS '每秒软中断次数';
COMMENT ON COLUMN public.device_cpu_monitor.syscalls_per_sec IS '每秒系统调用次数';
COMMENT ON COLUMN public.device_cpu_monitor.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_cpu_monitor.create_time IS '创建时间';


-- public.device_cpu_monitor_backup definition

-- Drop table

-- DROP TABLE device_cpu_monitor_backup;

CREATE TABLE device_cpu_monitor_backup (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 设备ID
	msg_id varchar(64) NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) NULL, -- 三级组织名称
	physical_cores int4 NULL, -- 物理核心数量
	logical_cores int4 NULL, -- 逻辑核心数量
	cpu_percent numeric(5, 2) NULL, -- 整体CPU使用率（百分比）
	load_average_1min numeric(5, 2) NULL, -- 1分钟系统负载平均值
	load_average_5min numeric(5, 2) NULL, -- 5分钟系统负载平均值
	load_average_15min numeric(5, 2) NULL, -- 15分钟系统负载平均值
	user_time numeric(15, 2) NULL, -- 用户态CPU时间（秒）
	system_time numeric(15, 2) NULL, -- 系统态CPU时间（秒）
	idle_time numeric(15, 2) NULL, -- CPU空闲时间（秒）
	nice_time numeric(15, 2) NULL, -- 低优先级用户态CPU时间（秒）
	iowait_time numeric(15, 2) NULL, -- CPU等待IO时间（秒）
	irq_time numeric(15, 2) NULL, -- CPU处理硬中断时间（秒）
	softirq_time numeric(15, 2) NULL, -- CPU处理软中断时间（秒）
	steal_time numeric(10, 2) NULL, -- 被虚拟机监控程序偷走的CPU时间（秒）
	user_percent numeric(5, 2) NULL, -- 用户态CPU使用率（百分比）
	system_percent numeric(5, 2) NULL, -- 系统态CPU使用率（百分比）
	idle_percent numeric(5, 2) NULL, -- CPU空闲率（百分比）
	nice_percent numeric(5, 2) NULL, -- 低优先级用户态CPU使用率（百分比）
	iowait_percent numeric(5, 2) NULL, -- CPU等待IO的百分比
	irq_percent numeric(5, 2) NULL, -- 硬中断占用CPU百分比
	softirq_percent numeric(5, 2) NULL, -- 软中断占用CPU百分比
	steal_percent numeric(5, 2) NULL, -- 被偷走的CPU时间百分比
	current_frequency numeric(10, 2) NULL, -- 当前CPU频率（MHz）
	min_frequency numeric(10, 2) NULL, -- 最小CPU频率（MHz）
	max_frequency numeric(10, 2) NULL, -- 最大CPU频率（MHz）
	cumulative_ctx_switches int8 NULL, -- 累计上下文切换次数
	cumulative_interrupts int8 NULL, -- 累计中断次数
	cumulative_soft_interrupts int8 NULL, -- 累计软中断次数
	cumulative_syscalls int8 NULL, -- 累计系统调用次数
	ctx_switches_per_sec numeric(10, 2) NULL, -- 每秒上下文切换次数
	interrupts_per_sec numeric(10, 2) NULL, -- 每秒中断次数
	soft_interrupts_per_sec numeric(10, 2) NULL, -- 每秒软中断次数
	syscalls_per_sec numeric(10, 2) NULL, -- 每秒系统调用次数
	collection_timestamp timestamp NOT NULL, -- 数据采集时间戳
	create_time timestamp NULL -- 创建时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_cpu_backup_device_collection ON device_cpu_monitor_backup USING btree (device_id DESC) LOCAL(PARTITION device_cpu_monitor_backup_y2025_device_id_idx, PARTITION device_cpu_monitor_backup_y2026_device_id_idx, PARTITION device_cpu_monitor_backup_y2027_device_id_idx, PARTITION device_cpu_monitor_backup_y2028_device_id_idx, PARTITION device_cpu_monitor_backup_y2029_device_id_idx, PARTITION device_cpu_monitor_backup_y2030_device_id_idx)  TABLESPACE pg_default;
COMMENT ON TABLE public.device_cpu_monitor_backup IS '归档表，CPU动态信息表，CPU的实时性能指标';

-- Column comments

COMMENT ON COLUMN public.device_cpu_monitor_backup.id IS '自增主键';
COMMENT ON COLUMN public.device_cpu_monitor_backup.device_id IS '设备ID';
COMMENT ON COLUMN public.device_cpu_monitor_backup.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_cpu_monitor_backup.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_cpu_monitor_backup.physical_cores IS '物理核心数量';
COMMENT ON COLUMN public.device_cpu_monitor_backup.logical_cores IS '逻辑核心数量';
COMMENT ON COLUMN public.device_cpu_monitor_backup.cpu_percent IS '整体CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.load_average_1min IS '1分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor_backup.load_average_5min IS '5分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor_backup.load_average_15min IS '15分钟系统负载平均值';
COMMENT ON COLUMN public.device_cpu_monitor_backup.user_time IS '用户态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.system_time IS '系统态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.idle_time IS 'CPU空闲时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.nice_time IS '低优先级用户态CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.iowait_time IS 'CPU等待IO时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.irq_time IS 'CPU处理硬中断时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.softirq_time IS 'CPU处理软中断时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.steal_time IS '被虚拟机监控程序偷走的CPU时间（秒）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.user_percent IS '用户态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.system_percent IS '系统态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.idle_percent IS 'CPU空闲率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.nice_percent IS '低优先级用户态CPU使用率（百分比）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.iowait_percent IS 'CPU等待IO的百分比';
COMMENT ON COLUMN public.device_cpu_monitor_backup.irq_percent IS '硬中断占用CPU百分比';
COMMENT ON COLUMN public.device_cpu_monitor_backup.softirq_percent IS '软中断占用CPU百分比';
COMMENT ON COLUMN public.device_cpu_monitor_backup.steal_percent IS '被偷走的CPU时间百分比';
COMMENT ON COLUMN public.device_cpu_monitor_backup.current_frequency IS '当前CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.min_frequency IS '最小CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.max_frequency IS '最大CPU频率（MHz）';
COMMENT ON COLUMN public.device_cpu_monitor_backup.cumulative_ctx_switches IS '累计上下文切换次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.cumulative_interrupts IS '累计中断次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.cumulative_soft_interrupts IS '累计软中断次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.cumulative_syscalls IS '累计系统调用次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.ctx_switches_per_sec IS '每秒上下文切换次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.interrupts_per_sec IS '每秒中断次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.soft_interrupts_per_sec IS '每秒软中断次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.syscalls_per_sec IS '每秒系统调用次数';
COMMENT ON COLUMN public.device_cpu_monitor_backup.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_cpu_monitor_backup.create_time IS '创建时间';


-- public.device_disk_monitor definition

-- Drop table

-- DROP TABLE device_disk_monitor;

CREATE TABLE device_disk_monitor (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 关联的设备ID
	msg_id varchar(64) DEFAULT NULL::character varying NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) DEFAULT NULL::character varying NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) DEFAULT NULL::character varying NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织名称
	total_space int8 NULL, -- 磁盘总空间（字节）
	used_space int8 NULL, -- 已使用磁盘空间（字节）
	free_space int8 NULL, -- 空闲磁盘空间（字节）
	usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 磁盘空间使用率（百分比）
	cumulative_read_count int8 NULL, -- 累计读操作次数
	cumulative_write_count int8 NULL, -- 累计写操作次数
	cumulative_read_bytes int8 NULL, -- 累计读字节数
	cumulative_write_bytes int8 NULL, -- 累计写字节数
	cumulative_read_time int4 NULL, -- 累计读操作时间（毫秒）
	cumulative_write_time int4 NULL, -- 累计写操作时间（毫秒）
	cumulative_busy_time int4 NULL, -- 磁盘累计繁忙时间（毫秒）
	read_iops numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒读操作数（IOPS）
	write_iops numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒写操作数（IOPS）
	read_bytes_per_sec int8 NULL, -- 每秒读字节数
	write_bytes_per_sec int8 NULL, -- 每秒写字节数
	read_speed_mbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 读速度（Mbps）
	write_speed_mbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 写速度（Mbps）
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT device_disk_monitor_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_desk_monitor_idx_msg_id ON device_disk_monitor USING btree (msg_id) TABLESPACE pg_default;
CREATE INDEX idx_disk_collection ON device_disk_monitor USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_disk_device ON device_disk_monitor USING btree (device_id) TABLESPACE pg_default;
CREATE INDEX idx_disk_device_collection ON device_disk_monitor USING btree (device_id, collection_timestamp DESC) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_disk_monitor.id IS '自增主键';
COMMENT ON COLUMN public.device_disk_monitor.device_id IS '关联的设备ID';
COMMENT ON COLUMN public.device_disk_monitor.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_disk_monitor.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_disk_monitor.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_disk_monitor.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_disk_monitor.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_disk_monitor.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_disk_monitor.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_disk_monitor.total_space IS '磁盘总空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor.used_space IS '已使用磁盘空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor.free_space IS '空闲磁盘空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor.usage_percent IS '磁盘空间使用率（百分比）';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_read_count IS '累计读操作次数';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_write_count IS '累计写操作次数';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_read_bytes IS '累计读字节数';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_write_bytes IS '累计写字节数';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_read_time IS '累计读操作时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_write_time IS '累计写操作时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor.cumulative_busy_time IS '磁盘累计繁忙时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor.read_iops IS '每秒读操作数（IOPS）';
COMMENT ON COLUMN public.device_disk_monitor.write_iops IS '每秒写操作数（IOPS）';
COMMENT ON COLUMN public.device_disk_monitor.read_bytes_per_sec IS '每秒读字节数';
COMMENT ON COLUMN public.device_disk_monitor.write_bytes_per_sec IS '每秒写字节数';
COMMENT ON COLUMN public.device_disk_monitor.read_speed_mbps IS '读速度（Mbps）';
COMMENT ON COLUMN public.device_disk_monitor.write_speed_mbps IS '写速度（Mbps）';
COMMENT ON COLUMN public.device_disk_monitor.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_disk_monitor.create_time IS '创建时间';


-- public.device_disk_monitor_backup definition

-- Drop table

-- DROP TABLE device_disk_monitor_backup;

CREATE TABLE device_disk_monitor_backup (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 关联的设备ID
	msg_id varchar(64) NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) NULL, -- 三级组织名称
	total_space int8 NULL, -- 磁盘总空间（字节）
	used_space int8 NULL, -- 已使用磁盘空间（字节）
	free_space int8 NULL, -- 空闲磁盘空间（字节）
	usage_percent numeric(5, 2) NULL, -- 磁盘空间使用率（百分比）
	cumulative_read_count int8 NULL, -- 累计读操作次数
	cumulative_write_count int8 NULL, -- 累计写操作次数
	cumulative_read_bytes int8 NULL, -- 累计读字节数
	cumulative_write_bytes int8 NULL, -- 累计写字节数
	cumulative_read_time int4 NULL, -- 累计读操作时间（毫秒）
	cumulative_write_time int4 NULL, -- 累计写操作时间（毫秒）
	cumulative_busy_time int4 NULL, -- 磁盘累计繁忙时间（毫秒）
	read_iops numeric(10, 2) NULL, -- 每秒读操作数（IOPS）
	write_iops numeric(10, 2) NULL, -- 每秒写操作数（IOPS）
	read_bytes_per_sec int8 NULL, -- 每秒读字节数
	write_bytes_per_sec int8 NULL, -- 每秒写字节数
	read_speed_mbps numeric(10, 2) NULL, -- 读速度（Mbps）
	write_speed_mbps numeric(10, 2) NULL, -- 写速度（Mbps）
	collection_timestamp timestamp NOT NULL, -- 数据采集时间戳
	create_time timestamp NULL -- 创建时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_disk_backup_device_collection ON device_disk_monitor_backup USING btree (device_id DESC) LOCAL(PARTITION device_disk_monitor_backup_y2025_device_id_idx, PARTITION device_disk_monitor_backup_y2026_device_id_idx, PARTITION device_disk_monitor_backup_y2027_device_id_idx, PARTITION device_disk_monitor_backup_y2028_device_id_idx, PARTITION device_disk_monitor_backup_y2029_device_id_idx, PARTITION device_disk_monitor_backup_y2030_device_id_idx)  TABLESPACE pg_default;
COMMENT ON TABLE public.device_disk_monitor_backup IS '磁盘动态信息表：磁盘的实时IO性能指标';

-- Column comments

COMMENT ON COLUMN public.device_disk_monitor_backup.id IS '自增主键';
COMMENT ON COLUMN public.device_disk_monitor_backup.device_id IS '关联的设备ID';
COMMENT ON COLUMN public.device_disk_monitor_backup.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_disk_monitor_backup.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_disk_monitor_backup.total_space IS '磁盘总空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor_backup.used_space IS '已使用磁盘空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor_backup.free_space IS '空闲磁盘空间（字节）';
COMMENT ON COLUMN public.device_disk_monitor_backup.usage_percent IS '磁盘空间使用率（百分比）';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_read_count IS '累计读操作次数';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_write_count IS '累计写操作次数';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_read_bytes IS '累计读字节数';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_write_bytes IS '累计写字节数';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_read_time IS '累计读操作时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_write_time IS '累计写操作时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor_backup.cumulative_busy_time IS '磁盘累计繁忙时间（毫秒）';
COMMENT ON COLUMN public.device_disk_monitor_backup.read_iops IS '每秒读操作数（IOPS）';
COMMENT ON COLUMN public.device_disk_monitor_backup.write_iops IS '每秒写操作数（IOPS）';
COMMENT ON COLUMN public.device_disk_monitor_backup.read_bytes_per_sec IS '每秒读字节数';
COMMENT ON COLUMN public.device_disk_monitor_backup.write_bytes_per_sec IS '每秒写字节数';
COMMENT ON COLUMN public.device_disk_monitor_backup.read_speed_mbps IS '读速度（Mbps）';
COMMENT ON COLUMN public.device_disk_monitor_backup.write_speed_mbps IS '写速度（Mbps）';
COMMENT ON COLUMN public.device_disk_monitor_backup.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_disk_monitor_backup.create_time IS '创建时间';


-- public.device_gpu_monitor definition

-- Drop table

-- DROP TABLE device_gpu_monitor;

CREATE TABLE device_gpu_monitor (
	id serial4 NOT NULL, -- 自增主键
	device_id int4 NOT NULL, -- 关联的设备ID
	msg_id varchar(64) DEFAULT NULL::character varying NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) DEFAULT NULL::character varying NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) DEFAULT NULL::character varying NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织名称
	gpu_count int4 NULL, -- GPU总数
	total_memory_mb int4 NULL, -- 总显存（所有GPU合计，MB）
	used_memory_mb int4 NULL, -- 已使用显存（所有GPU合计，MB）
	free_memory_mb int4 NULL, -- 空闲显存（所有GPU合计，MB）
	memory_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 平均显存使用率（百分比）
	avg_gpu_utilization numeric(5, 2) DEFAULT NULL::numeric NULL, -- 平均GPU核心利用率（百分比）
	avg_memory_utilization numeric(5, 2) DEFAULT NULL::numeric NULL, -- 平均显存利用率（百分比）
	max_gpu_utilization int4 NULL, -- 最高GPU核心利用率（百分比）
	min_gpu_utilization int4 NULL, -- 最低GPU核心利用率（百分比）
	avg_temperature numeric(5, 2) DEFAULT NULL::numeric NULL, -- 平均温度（摄氏度）
	max_temperature int4 NULL, -- 最高温度（摄氏度）
	total_power_draw numeric(10, 2) DEFAULT NULL::numeric NULL, -- 总功耗（所有GPU合计，瓦特）
	total_power_limit numeric(10, 2) DEFAULT NULL::numeric NULL, -- 总功耗限制（所有GPU合计，瓦特）
	power_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 平均功耗使用率（百分比）
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT device_gpu_monitor_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_gpu_monitor__idx_msg_id ON device_gpu_monitor USING btree (msg_id) TABLESPACE pg_default;
CREATE INDEX device_gpu_monitor_idx_device_timestamp ON device_gpu_monitor USING btree (device_id, collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_gpu_collection ON device_gpu_monitor USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_gpu_device ON device_gpu_monitor USING btree (device_id) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_gpu_monitor.id IS '自增主键';
COMMENT ON COLUMN public.device_gpu_monitor.device_id IS '关联的设备ID';
COMMENT ON COLUMN public.device_gpu_monitor.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_gpu_monitor.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_gpu_monitor.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_gpu_monitor.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_gpu_monitor.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_gpu_monitor.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_gpu_monitor.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_gpu_monitor.gpu_count IS 'GPU总数';
COMMENT ON COLUMN public.device_gpu_monitor.total_memory_mb IS '总显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor.used_memory_mb IS '已使用显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor.free_memory_mb IS '空闲显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor.memory_usage_percent IS '平均显存使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.avg_gpu_utilization IS '平均GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.avg_memory_utilization IS '平均显存利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.max_gpu_utilization IS '最高GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.min_gpu_utilization IS '最低GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.avg_temperature IS '平均温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor.max_temperature IS '最高温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor.total_power_draw IS '总功耗（所有GPU合计，瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor.total_power_limit IS '总功耗限制（所有GPU合计，瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor.power_usage_percent IS '平均功耗使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_gpu_monitor.create_time IS '创建时间';


-- public.device_gpu_monitor_backup definition

-- Drop table

-- DROP TABLE device_gpu_monitor_backup;

CREATE TABLE device_gpu_monitor_backup (
	id serial4 NOT NULL, -- 自增主键
	device_id int4 NOT NULL, -- 关联的设备ID
	msg_id varchar(64) NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) NULL, -- 三级组织名称
	gpu_count int4 NULL, -- GPU总数
	total_memory_mb int4 NULL, -- 总显存（所有GPU合计，MB）
	used_memory_mb int4 NULL, -- 已使用显存（所有GPU合计，MB）
	free_memory_mb int4 NULL, -- 空闲显存（所有GPU合计，MB）
	memory_usage_percent numeric(5, 2) NULL, -- 平均显存使用率（百分比）
	avg_gpu_utilization numeric(5, 2) NULL, -- 平均GPU核心利用率（百分比）
	avg_memory_utilization numeric(5, 2) NULL, -- 平均显存利用率（百分比）
	max_gpu_utilization int4 NULL, -- 最高GPU核心利用率（百分比）
	min_gpu_utilization int4 NULL, -- 最低GPU核心利用率（百分比）
	avg_temperature numeric(5, 2) NULL, -- 平均温度（摄氏度）
	max_temperature int4 NULL, -- 最高温度（摄氏度）
	total_power_draw numeric(10, 2) NULL, -- 总功耗（所有GPU合计，瓦特）
	total_power_limit numeric(10, 2) NULL, -- 总功耗限制（所有GPU合计，瓦特）
	power_usage_percent numeric(5, 2) NULL, -- 平均功耗使用率（百分比）
	collection_timestamp timestamp NOT NULL, -- 数据采集时间戳
	create_time timestamp NULL -- 创建时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_gpu_backup_device_collection ON device_gpu_monitor_backup USING btree (device_id DESC) LOCAL(PARTITION device_gpu_monitor_backup_y2025_device_id_idx, PARTITION device_gpu_monitor_backup_y2026_device_id_idx, PARTITION device_gpu_monitor_backup_y2027_device_id_idx, PARTITION device_gpu_monitor_backup_y2028_device_id_idx, PARTITION device_gpu_monitor_backup_y2029_device_id_idx, PARTITION device_gpu_monitor_backup_y2030_device_id_idx)  TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_gpu_monitor_backup.id IS '自增主键';
COMMENT ON COLUMN public.device_gpu_monitor_backup.device_id IS '关联的设备ID';
COMMENT ON COLUMN public.device_gpu_monitor_backup.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_gpu_monitor_backup.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_gpu_monitor_backup.gpu_count IS 'GPU总数';
COMMENT ON COLUMN public.device_gpu_monitor_backup.total_memory_mb IS '总显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.used_memory_mb IS '已使用显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.free_memory_mb IS '空闲显存（所有GPU合计，MB）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.memory_usage_percent IS '平均显存使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.avg_gpu_utilization IS '平均GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.avg_memory_utilization IS '平均显存利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.max_gpu_utilization IS '最高GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.min_gpu_utilization IS '最低GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.avg_temperature IS '平均温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.max_temperature IS '最高温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.total_power_draw IS '总功耗（所有GPU合计，瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.total_power_limit IS '总功耗限制（所有GPU合计，瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.power_usage_percent IS '平均功耗使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_backup.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_gpu_monitor_backup.create_time IS '创建时间';


-- public.device_gpu_monitor_detail definition

-- Drop table

-- DROP TABLE device_gpu_monitor_detail;

CREATE TABLE device_gpu_monitor_detail (
	id bigserial NOT NULL, -- 自增主键
	device_gpu_monitor_id int8 NOT NULL, -- 关联的GPU汇总device_gpu_monitor ID
	gpu_idx int4 NOT NULL, -- GPU索引
	gpu_name varchar(100) DEFAULT NULL::character varying NULL, -- GPU名称（如：NVIDIA H100 80GB HBM3）
	total_mb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 总显存（MB）
	used_mb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 已使用显存（MB）
	free_mb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 空闲显存（MB）
	usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 显存使用率（百分比）
	gpu_utilization_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU核心利用率（百分比）
	memory_utilization_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 显存利用率（百分比）
	current_gpu_clock_mhz int4 NULL, -- 当前GPU核心频率（MHz）
	current_memory_clock_mhz int4 NULL, -- 当前显存频率（MHz）
	temperature_celsius numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU温度（摄氏度）
	power_draw_watts numeric(10, 2) DEFAULT NULL::numeric NULL, -- 当前功耗（瓦特）
	power_limit_watts numeric(10, 2) DEFAULT NULL::numeric NULL, -- 功耗限制（瓦特）
	power_usage_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 功耗使用率（百分比）
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	CONSTRAINT device_gpu_monitor_detail_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_gpu_monitor_detail_idx_collection_timestamp ON device_gpu_monitor_detail USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX device_gpu_monitor_detail_idx_gpu_idx ON device_gpu_monitor_detail USING btree (gpu_idx) TABLESPACE pg_default;
CREATE INDEX device_gpu_monitor_detail_idx_summary_gpu ON device_gpu_monitor_detail USING btree (device_gpu_monitor_id, gpu_idx) TABLESPACE pg_default;
CREATE INDEX device_gpu_monitor_detail_idx_summary_id ON device_gpu_monitor_detail USING btree (device_gpu_monitor_id) TABLESPACE pg_default;
CREATE INDEX idx_gpu_detail_collection ON device_gpu_monitor_detail USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_gpu_detail_monitor ON device_gpu_monitor_detail USING btree (device_gpu_monitor_id) TABLESPACE pg_default;
CREATE INDEX idx_gpu_detail_monitor_collection ON device_gpu_monitor_detail USING btree (device_gpu_monitor_id, collection_timestamp DESC) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_gpu_monitor_detail.id IS '自增主键';
COMMENT ON COLUMN public.device_gpu_monitor_detail.device_gpu_monitor_id IS '关联的GPU汇总device_gpu_monitor ID';
COMMENT ON COLUMN public.device_gpu_monitor_detail.gpu_idx IS 'GPU索引';
COMMENT ON COLUMN public.device_gpu_monitor_detail.gpu_name IS 'GPU名称（如：NVIDIA H100 80GB HBM3）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.total_mb IS '总显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.used_mb IS '已使用显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.free_mb IS '空闲显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.usage_percent IS '显存使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.gpu_utilization_percent IS 'GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.memory_utilization_percent IS '显存利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.current_gpu_clock_mhz IS '当前GPU核心频率（MHz）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.current_memory_clock_mhz IS '当前显存频率（MHz）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.temperature_celsius IS 'GPU温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.power_draw_watts IS '当前功耗（瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.power_limit_watts IS '功耗限制（瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.power_usage_percent IS '功耗使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_gpu_monitor_detail.create_time IS '创建时间';
COMMENT ON COLUMN public.device_gpu_monitor_detail.update_time IS '更新时间';


-- public.device_gpu_monitor_detail_backup definition

-- Drop table

-- DROP TABLE device_gpu_monitor_detail_backup;

CREATE TABLE device_gpu_monitor_detail_backup (
	id bigserial NOT NULL, -- 自增主键
	device_gpu_monitor_id int8 NOT NULL, -- 关联的GPU汇总device_gpu_monitor ID
	gpu_idx int4 NOT NULL, -- GPU索引
	gpu_name varchar(100) NULL, -- GPU名称（如：NVIDIA H100 80GB HBM3）
	total_mb numeric(10, 2) NULL, -- 总显存（MB）
	used_mb numeric(10, 2) NULL, -- 已使用显存（MB）
	free_mb numeric(10, 2) NULL, -- 空闲显存（MB）
	usage_percent numeric(5, 2) NULL, -- 显存使用率（百分比）
	gpu_utilization_percent numeric(5, 2) NULL, -- GPU核心利用率（百分比）
	memory_utilization_percent numeric(5, 2) NULL, -- 显存利用率（百分比）
	current_gpu_clock_mhz int4 NULL, -- 当前GPU核心频率（MHz）
	current_memory_clock_mhz int4 NULL, -- 当前显存频率（MHz）
	temperature_celsius numeric(5, 2) NULL, -- GPU温度（摄氏度）
	power_draw_watts numeric(10, 2) NULL, -- 当前功耗（瓦特）
	power_limit_watts numeric(10, 2) NULL, -- 功耗限制（瓦特）
	power_usage_percent numeric(5, 2) NULL, -- 功耗使用率（百分比）
	collection_timestamp timestamp NOT NULL, -- 数据采集时间戳
	create_time timestamp NULL, -- 创建时间
	update_time timestamp NULL -- 更新时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_gpu_detail_backup_monitor_collection ON device_gpu_monitor_detail_backup USING btree (device_gpu_monitor_id DESC) LOCAL(PARTITION device_gpu_monitor_detail_backup_y202_device_gpu_monitor_id_idx, PARTITION device_gpu_monitor_detail_backup_y20_device_gpu_monitor_id_idx1, PARTITION device_gpu_monitor_detail_backup_y20_device_gpu_monitor_id_idx2, PARTITION device_gpu_monitor_detail_backup_y20_device_gpu_monitor_id_idx3, PARTITION device_gpu_monitor_detail_backup_y20_device_gpu_monitor_id_idx4, PARTITION device_gpu_monitor_detail_backup_y203_device_gpu_monitor_id_idx)  TABLESPACE pg_default;
COMMENT ON TABLE public.device_gpu_monitor_detail_backup IS 'GPU动态信息明细表';

-- Column comments

COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.id IS '自增主键';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.device_gpu_monitor_id IS '关联的GPU汇总device_gpu_monitor ID';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.gpu_idx IS 'GPU索引';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.gpu_name IS 'GPU名称（如：NVIDIA H100 80GB HBM3）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.total_mb IS '总显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.used_mb IS '已使用显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.free_mb IS '空闲显存（MB）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.usage_percent IS '显存使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.gpu_utilization_percent IS 'GPU核心利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.memory_utilization_percent IS '显存利用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.current_gpu_clock_mhz IS '当前GPU核心频率（MHz）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.current_memory_clock_mhz IS '当前显存频率（MHz）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.temperature_celsius IS 'GPU温度（摄氏度）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.power_draw_watts IS '当前功耗（瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.power_limit_watts IS '功耗限制（瓦特）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.power_usage_percent IS '功耗使用率（百分比）';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.create_time IS '创建时间';
COMMENT ON COLUMN public.device_gpu_monitor_detail_backup.update_time IS '更新时间';


-- public.device_memory_monitor definition

-- Drop table

-- DROP TABLE device_memory_monitor;

CREATE TABLE device_memory_monitor (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 设备ID
	msg_id varchar(64) DEFAULT NULL::character varying NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) DEFAULT NULL::character varying NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) DEFAULT NULL::character varying NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织名称
	virtual_total int8 NULL, -- 总虚拟内存（字节）
	virtual_available int8 NULL, -- 可用虚拟内存（字节）
	virtual_used int8 NULL, -- 已使用虚拟内存（字节）
	virtual_free int8 NULL, -- 空闲虚拟内存（字节）
	virtual_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 虚拟内存使用率（百分比）
	virtual_active int8 NULL, -- 活跃使用的虚拟内存（字节）
	virtual_inactive int8 NULL, -- 非活跃的虚拟内存（字节）
	virtual_buffers int8 NULL, -- 用于缓冲区的虚拟内存（字节）
	virtual_cached int8 NULL, -- 用于缓存的虚拟内存（字节）
	virtual_shared int8 NULL, -- 被共享使用的虚拟内存（字节）
	virtual_slab int8 NULL, -- 内核slab分配器使用的内存（字节）
	swap_total int8 NULL, -- 交换分区总大小（字节）
	swap_used int8 NULL, -- 已使用交换分区大小（字节）
	swap_free int8 NULL, -- 空闲交换分区大小（字节）
	swap_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 交换分区使用率（百分比）
	swap_sin int8 NULL, -- 累计从磁盘换入的内存量（字节）
	swap_sout int8 NULL, -- 累计换出到磁盘的内存量（字节）
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT device_memory_monitor_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_memory_monitor_idx_device_timestamp ON device_memory_monitor USING btree (device_id, collection_timestamp) TABLESPACE pg_default;
CREATE INDEX device_memory_monitor_idx_msg_id ON device_memory_monitor USING btree (msg_id) TABLESPACE pg_default;
CREATE INDEX idx_memory_collection ON device_memory_monitor USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_memory_device ON device_memory_monitor USING btree (device_id) TABLESPACE pg_default;
CREATE INDEX idx_memory_device_collection ON device_memory_monitor USING btree (device_id, collection_timestamp DESC) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_memory_monitor.id IS '自增主键';
COMMENT ON COLUMN public.device_memory_monitor.device_id IS '设备ID';
COMMENT ON COLUMN public.device_memory_monitor.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_memory_monitor.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_memory_monitor.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_memory_monitor.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_memory_monitor.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_memory_monitor.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_memory_monitor.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_memory_monitor.virtual_total IS '总虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_available IS '可用虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_used IS '已使用虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_free IS '空闲虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_percent IS '虚拟内存使用率（百分比）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_active IS '活跃使用的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_inactive IS '非活跃的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_buffers IS '用于缓冲区的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_cached IS '用于缓存的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_shared IS '被共享使用的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.virtual_slab IS '内核slab分配器使用的内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor.swap_total IS '交换分区总大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor.swap_used IS '已使用交换分区大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor.swap_free IS '空闲交换分区大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor.swap_percent IS '交换分区使用率（百分比）';
COMMENT ON COLUMN public.device_memory_monitor.swap_sin IS '累计从磁盘换入的内存量（字节）';
COMMENT ON COLUMN public.device_memory_monitor.swap_sout IS '累计换出到磁盘的内存量（字节）';
COMMENT ON COLUMN public.device_memory_monitor.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_memory_monitor.create_time IS '创建时间';


-- public.device_memory_monitor_backup definition

-- Drop table

-- DROP TABLE device_memory_monitor_backup;

CREATE TABLE device_memory_monitor_backup (
	id bigserial NOT NULL, -- 自增主键
	device_id int8 NOT NULL, -- 设备ID
	msg_id varchar(64) NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) NULL, -- 三级组织名称
	virtual_total int8 NULL, -- 总虚拟内存（字节）
	virtual_available int8 NULL, -- 可用虚拟内存（字节）
	virtual_used int8 NULL, -- 已使用虚拟内存（字节）
	virtual_free int8 NULL, -- 空闲虚拟内存（字节）
	virtual_percent numeric(5, 2) NULL, -- 虚拟内存使用率（百分比）
	virtual_active int8 NULL, -- 活跃使用的虚拟内存（字节）
	virtual_inactive int8 NULL, -- 非活跃的虚拟内存（字节）
	virtual_buffers int8 NULL, -- 用于缓冲区的虚拟内存（字节）
	virtual_cached int8 NULL, -- 用于缓存的虚拟内存（字节）
	virtual_shared int8 NULL, -- 被共享使用的虚拟内存（字节）
	virtual_slab int8 NULL, -- 内核slab分配器使用的内存（字节）
	swap_total int8 NULL, -- 交换分区总大小（字节）
	swap_used int8 NULL, -- 已使用交换分区大小（字节）
	swap_free int8 NULL, -- 空闲交换分区大小（字节）
	swap_percent numeric(5, 2) NULL, -- 交换分区使用率（百分比）
	swap_sin int8 NULL, -- 累计从磁盘换入的内存量（字节）
	swap_sout int8 NULL, -- 累计换出到磁盘的内存量（字节）
	collection_timestamp timestamp NOT NULL, -- 数据采集时间戳
	create_time timestamp NULL -- 创建时间
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_memory_backup_device_collection ON device_memory_monitor_backup USING btree (device_id DESC) LOCAL(PARTITION device_memory_monitor_backup_y2025_device_id_idx, PARTITION device_memory_monitor_backup_y2026_device_id_idx, PARTITION device_memory_monitor_backup_y2027_device_id_idx, PARTITION device_memory_monitor_backup_y2028_device_id_idx, PARTITION device_memory_monitor_backup_y2029_device_id_idx, PARTITION device_memory_monitor_backup_y2030_device_id_idx)  TABLESPACE pg_default;
COMMENT ON TABLE public.device_memory_monitor_backup IS '内存动态信息表，内存和交换分区的实时使用情况';

-- Column comments

COMMENT ON COLUMN public.device_memory_monitor_backup.id IS '自增主键';
COMMENT ON COLUMN public.device_memory_monitor_backup.device_id IS '设备ID';
COMMENT ON COLUMN public.device_memory_monitor_backup.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_memory_monitor_backup.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_total IS '总虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_available IS '可用虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_used IS '已使用虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_free IS '空闲虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_percent IS '虚拟内存使用率（百分比）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_active IS '活跃使用的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_inactive IS '非活跃的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_buffers IS '用于缓冲区的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_cached IS '用于缓存的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_shared IS '被共享使用的虚拟内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.virtual_slab IS '内核slab分配器使用的内存（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_total IS '交换分区总大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_used IS '已使用交换分区大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_free IS '空闲交换分区大小（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_percent IS '交换分区使用率（百分比）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_sin IS '累计从磁盘换入的内存量（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.swap_sout IS '累计换出到磁盘的内存量（字节）';
COMMENT ON COLUMN public.device_memory_monitor_backup.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_memory_monitor_backup.create_time IS '创建时间';


-- public.device_network_monitor definition

-- Drop table

-- DROP TABLE device_network_monitor;

CREATE TABLE device_network_monitor (
	id serial4 NOT NULL, -- 自增主键
	device_id int4 NOT NULL, -- 关联的设备ID
	msg_id varchar(64) DEFAULT NULL::character varying NULL, -- 消息UUID（唯一标识）
	organization_id1 int8 NULL, -- 根组织ID
	organization_name1 varchar(100) DEFAULT NULL::character varying NULL, -- 根组织名称
	organization_id2 int8 NULL, -- 二级组织ID
	organization_name2 varchar(100) DEFAULT NULL::character varying NULL, -- 二级组织名称
	organization_id3 int8 NULL, -- 三级组织ID
	organization_name3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织名称
	cumulative_bytes_sent int8 NULL, -- 累计发送字节数
	cumulative_bytes_recv int8 NULL, -- 累计接收字节数
	cumulative_packets_sent int4 NULL, -- 累计发送数据包数
	cumulative_packets_recv int4 NULL, -- 累计接收数据包数
	cumulative_errin int4 NULL, -- 累计接收错误数
	cumulative_errout int4 NULL, -- 累计发送错误数
	cumulative_dropin int4 NULL, -- 累计接收丢弃数据包数
	cumulative_dropout int4 NULL, -- 累计发送丢弃数据包数
	bytes_recv_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒接收字节数
	bytes_sent_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒发送字节数
	packets_recv_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒接收数据包数
	packets_sent_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒发送数据包数
	errin_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒接收错误数
	errout_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒发送错误数
	dropin_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒接收丢弃数
	dropout_per_sec numeric(10, 2) DEFAULT NULL::numeric NULL, -- 每秒发送丢弃数
	download_speed_mbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 下载速度（Mbps）
	upload_speed_mbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 上传速度（Mbps）
	download_speed_kbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 下载速度（Kbps）
	upload_speed_kbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 上传速度（Kbps）
	collection_timestamp timestamp(0) NOT NULL, -- 数据采集时间戳
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT device_network_monitor_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX device_network_monitor_idx_msg_id ON device_network_monitor USING btree (msg_id) TABLESPACE pg_default;
CREATE INDEX idx_network_collection ON device_network_monitor USING btree (collection_timestamp) TABLESPACE pg_default;
CREATE INDEX idx_network_device ON device_network_monitor USING btree (device_id) TABLESPACE pg_default;
CREATE INDEX idx_network_device_collection ON device_network_monitor USING btree (device_id, collection_timestamp DESC) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.device_network_monitor.id IS '自增主键';
COMMENT ON COLUMN public.device_network_monitor.device_id IS '关联的设备ID';
COMMENT ON COLUMN public.device_network_monitor.msg_id IS '消息UUID（唯一标识）';
COMMENT ON COLUMN public.device_network_monitor.organization_id1 IS '根组织ID';
COMMENT ON COLUMN public.device_network_monitor.organization_name1 IS '根组织名称';
COMMENT ON COLUMN public.device_network_monitor.organization_id2 IS '二级组织ID';
COMMENT ON COLUMN public.device_network_monitor.organization_name2 IS '二级组织名称';
COMMENT ON COLUMN public.device_network_monitor.organization_id3 IS '三级组织ID';
COMMENT ON COLUMN public.device_network_monitor.organization_name3 IS '三级组织名称';
COMMENT ON COLUMN public.device_network_monitor.cumulative_bytes_sent IS '累计发送字节数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_bytes_recv IS '累计接收字节数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_packets_sent IS '累计发送数据包数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_packets_recv IS '累计接收数据包数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_errin IS '累计接收错误数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_errout IS '累计发送错误数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_dropin IS '累计接收丢弃数据包数';
COMMENT ON COLUMN public.device_network_monitor.cumulative_dropout IS '累计发送丢弃数据包数';
COMMENT ON COLUMN public.device_network_monitor.bytes_recv_per_sec IS '每秒接收字节数';
COMMENT ON COLUMN public.device_network_monitor.bytes_sent_per_sec IS '每秒发送字节数';
COMMENT ON COLUMN public.device_network_monitor.packets_recv_per_sec IS '每秒接收数据包数';
COMMENT ON COLUMN public.device_network_monitor.packets_sent_per_sec IS '每秒发送数据包数';
COMMENT ON COLUMN public.device_network_monitor.errin_per_sec IS '每秒接收错误数';
COMMENT ON COLUMN public.device_network_monitor.errout_per_sec IS '每秒发送错误数';
COMMENT ON COLUMN public.device_network_monitor.dropin_per_sec IS '每秒接收丢弃数';
COMMENT ON COLUMN public.device_network_monitor.dropout_per_sec IS '每秒发送丢弃数';
COMMENT ON COLUMN public.device_network_monitor.download_speed_mbps IS '下载速度（Mbps）';
COMMENT ON COLUMN public.device_network_monitor.upload_speed_mbps IS '上传速度（Mbps）';
COMMENT ON COLUMN public.device_network_monitor.download_speed_kbps IS '下载速度（Kbps）';
COMMENT ON COLUMN public.device_network_monitor.upload_speed_kbps IS '上传速度（Kbps）';
COMMENT ON COLUMN public.device_network_monitor.collection_timestamp IS '数据采集时间戳';
COMMENT ON COLUMN public.device_network_monitor.create_time IS '创建时间';


-- public.device_network_monitor_backup definition

-- Drop table

-- DROP TABLE device_network_monitor_backup;

CREATE TABLE device_network_monitor_backup (
	id serial4 NOT NULL,
	device_id int4 NOT NULL,
	msg_id varchar(64) NULL,
	organization_id1 int8 NULL,
	organization_name1 varchar(100) NULL,
	organization_id2 int8 NULL,
	organization_name2 varchar(100) NULL,
	organization_id3 int8 NULL,
	organization_name3 varchar(100) NULL,
	cumulative_bytes_sent int8 NULL,
	cumulative_bytes_recv int8 NULL,
	cumulative_packets_sent int4 NULL,
	cumulative_packets_recv int4 NULL,
	cumulative_errin int4 NULL,
	cumulative_errout int4 NULL,
	cumulative_dropin int4 NULL,
	cumulative_dropout int4 NULL,
	bytes_recv_per_sec numeric(10, 2) NULL,
	bytes_sent_per_sec numeric(10, 2) NULL,
	packets_recv_per_sec numeric(10, 2) NULL,
	packets_sent_per_sec numeric(10, 2) NULL,
	errin_per_sec numeric(10, 2) NULL,
	errout_per_sec numeric(10, 2) NULL,
	dropin_per_sec numeric(10, 2) NULL,
	dropout_per_sec numeric(10, 2) NULL,
	download_speed_mbps numeric(10, 2) NULL,
	upload_speed_mbps numeric(10, 2) NULL,
	download_speed_kbps numeric(10, 2) NULL,
	upload_speed_kbps numeric(10, 2) NULL,
	collection_timestamp timestamp NOT NULL,
	create_time timestamp NULL
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_network_backup_device_collection ON device_network_monitor_backup USING btree (device_id DESC) LOCAL(PARTITION device_network_monitor_backup_y2025_device_id_idx, PARTITION device_network_monitor_backup_y2026_device_id_idx, PARTITION device_network_monitor_backup_y2027_device_id_idx, PARTITION device_network_monitor_backup_y2028_device_id_idx, PARTITION device_network_monitor_backup_y2029_device_id_idx, PARTITION device_network_monitor_backup_y2030_device_id_idx)  TABLESPACE pg_default;


-- public.dic_info definition

-- Drop table

-- DROP TABLE dic_info;

CREATE TABLE dic_info (
	id bigserial NOT NULL, -- id
	code varchar(30) DEFAULT NULL::character varying NULL, -- 编码
	"name" varchar(100) DEFAULT NULL::character varying NULL, -- 名称
	value varchar(100) DEFAULT NULL::character varying NULL,
	"type" int2 NULL, -- 1 网络模块
	CONSTRAINT dic_info_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);

-- Column comments

COMMENT ON COLUMN public.dic_info.id IS 'id';
COMMENT ON COLUMN public.dic_info.code IS '编码';
COMMENT ON COLUMN public.dic_info."name" IS '名称';
COMMENT ON COLUMN public.dic_info."type" IS '1 网络模块';


-- public.gpu_card_info definition

-- Drop table

-- DROP TABLE gpu_card_info;

CREATE TABLE gpu_card_info (
	id bigserial NOT NULL, -- GPU卡信息ID
	gpu_index int4 NOT NULL, -- GPU索引编号
	gpu_name varchar(100) NOT NULL, -- GPU名称（如：RTX 4090, H100）
	card_type int4 NULL, -- 卡类型: 1-高端卡 2-中端卡 3-低端卡
	cuda_cores int4 NULL, -- CUDA核心数
	base_clock_mhz int4 NULL, -- 基础频率（MHz）
	boost_clock_mhz int4 NULL, -- 加速频率（MHz）
	memory_total_mb int4 NULL, -- 显存容量（MB）
	memory_total_gb numeric(10, 2) DEFAULT NULL::numeric NULL, -- 显存容量（GB）
	pcie_gen int4 NULL, -- PCIe版本（如：3, 4, 5）
	pcie_width int4 NULL, -- PCIe通道宽度（如：8, 16）
	tflops_fp32 numeric(10, 2) DEFAULT NULL::numeric NULL, -- 单精度浮点性能（TFLOPS）
	tflops_fp16 numeric(10, 2) DEFAULT NULL::numeric NULL, -- 半精度浮点性能（TFLOPS）
	tflops_fp64 numeric(10, 2) DEFAULT NULL::numeric NULL, -- 双精度浮点性能（TFLOPS）
	tflops_int8 numeric(10, 2) DEFAULT NULL::numeric NULL, -- INT8性能（TOPS）
	tdp_watts int4 NULL, -- 热设计功耗（瓦特）
	max_power_watts int4 NULL, -- 最大功耗（瓦特）
	memory_type varchar(50) DEFAULT NULL::character varying NULL, -- 显存类型（如：GDDR6X, HBM3）
	memory_bus_width int4 NULL, -- 显存位宽（bit）
	memory_bandwidth_gbps numeric(10, 2) DEFAULT NULL::numeric NULL, -- 显存带宽（GB/s）
	architecture varchar(50) DEFAULT NULL::character varying NULL, -- GPU架构（如：Ada Lovelace, Hopper）
	compute_capability varchar(20) DEFAULT NULL::character varying NULL, -- CUDA计算能力版本（如：8.9）
	status int2 DEFAULT 1::smallint NULL, -- 状态: 0-离线 1-在线 2-故障
	remark varchar(500) DEFAULT NULL::character varying NULL, -- 备注
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by varchar(50) DEFAULT NULL::character varying NULL, -- 创建人
	update_by varchar(50) DEFAULT NULL::character varying NULL, -- 更新人
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	"version" int4 DEFAULT 0 NULL, -- 版本号
	CONSTRAINT gpu_card_info_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX gpu_card_info_idx_card_type ON gpu_card_info USING btree (card_type) TABLESPACE pg_default;
CREATE INDEX gpu_card_info_idx_deleted ON gpu_card_info USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX gpu_card_info_idx_gpu_name ON gpu_card_info USING btree (gpu_name) TABLESPACE pg_default;
CREATE INDEX gpu_card_info_idx_status ON gpu_card_info USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.gpu_card_info.id IS 'GPU卡信息ID';
COMMENT ON COLUMN public.gpu_card_info.gpu_index IS 'GPU索引编号';
COMMENT ON COLUMN public.gpu_card_info.gpu_name IS 'GPU名称（如：RTX 4090, H100）';
COMMENT ON COLUMN public.gpu_card_info.card_type IS '卡类型: 1-高端卡 2-中端卡 3-低端卡';
COMMENT ON COLUMN public.gpu_card_info.cuda_cores IS 'CUDA核心数';
COMMENT ON COLUMN public.gpu_card_info.base_clock_mhz IS '基础频率（MHz）';
COMMENT ON COLUMN public.gpu_card_info.boost_clock_mhz IS '加速频率（MHz）';
COMMENT ON COLUMN public.gpu_card_info.memory_total_mb IS '显存容量（MB）';
COMMENT ON COLUMN public.gpu_card_info.memory_total_gb IS '显存容量（GB）';
COMMENT ON COLUMN public.gpu_card_info.pcie_gen IS 'PCIe版本（如：3, 4, 5）';
COMMENT ON COLUMN public.gpu_card_info.pcie_width IS 'PCIe通道宽度（如：8, 16）';
COMMENT ON COLUMN public.gpu_card_info.tflops_fp32 IS '单精度浮点性能（TFLOPS）';
COMMENT ON COLUMN public.gpu_card_info.tflops_fp16 IS '半精度浮点性能（TFLOPS）';
COMMENT ON COLUMN public.gpu_card_info.tflops_fp64 IS '双精度浮点性能（TFLOPS）';
COMMENT ON COLUMN public.gpu_card_info.tflops_int8 IS 'INT8性能（TOPS）';
COMMENT ON COLUMN public.gpu_card_info.tdp_watts IS '热设计功耗（瓦特）';
COMMENT ON COLUMN public.gpu_card_info.max_power_watts IS '最大功耗（瓦特）';
COMMENT ON COLUMN public.gpu_card_info.memory_type IS '显存类型（如：GDDR6X, HBM3）';
COMMENT ON COLUMN public.gpu_card_info.memory_bus_width IS '显存位宽（bit）';
COMMENT ON COLUMN public.gpu_card_info.memory_bandwidth_gbps IS '显存带宽（GB/s）';
COMMENT ON COLUMN public.gpu_card_info.architecture IS 'GPU架构（如：Ada Lovelace, Hopper）';
COMMENT ON COLUMN public.gpu_card_info.compute_capability IS 'CUDA计算能力版本（如：8.9）';
COMMENT ON COLUMN public.gpu_card_info.status IS '状态: 0-离线 1-在线 2-故障';
COMMENT ON COLUMN public.gpu_card_info.remark IS '备注';
COMMENT ON COLUMN public.gpu_card_info.create_time IS '创建时间';
COMMENT ON COLUMN public.gpu_card_info.update_time IS '更新时间';
COMMENT ON COLUMN public.gpu_card_info.create_by IS '创建人';
COMMENT ON COLUMN public.gpu_card_info.update_by IS '更新人';
COMMENT ON COLUMN public.gpu_card_info.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.gpu_card_info."version" IS '版本号';


-- public.network definition

-- Drop table

-- DROP TABLE network;

CREATE TABLE network (
	id bigserial NOT NULL, -- 主键
	code varchar(100) NULL, -- 网络code
	parent_code varchar(100) NULL, -- 网络父code
	"name" varchar(100) NULL, -- 网络名称
	create_time timestamp DEFAULT now() NULL, -- 创建时间
	update_time timestamp DEFAULT now() NULL, -- 更新时间
	create_by varchar(50) NULL, -- 创建人
	update_by varchar(50) NULL, -- 更新人
	deleted int4 DEFAULT 0 NULL, -- 删除标志: 0-未删除 1-已删除
	CONSTRAINT network_pk PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
COMMENT ON TABLE public.network IS '网络模块';

-- Column comments

COMMENT ON COLUMN public.network.id IS '主键';
COMMENT ON COLUMN public.network.code IS '网络code';
COMMENT ON COLUMN public.network.parent_code IS '网络父code';
COMMENT ON COLUMN public.network."name" IS '网络名称';
COMMENT ON COLUMN public.network.create_time IS '创建时间';
COMMENT ON COLUMN public.network.update_time IS '更新时间';
COMMENT ON COLUMN public.network.create_by IS '创建人';
COMMENT ON COLUMN public.network.update_by IS '更新人';
COMMENT ON COLUMN public.network.deleted IS '删除标志: 0-未删除 1-已删除';


-- public.org_gpu_usage_summary definition

-- Drop table

-- DROP TABLE org_gpu_usage_summary;

CREATE TABLE org_gpu_usage_summary (
	id bigserial NOT NULL, -- 主键ID
	organization_id1 int8 NULL, -- 一级组织机构ID
	organization_name1 varchar(200) DEFAULT NULL::character varying NULL, -- 一级组织机构名称
	organization_id2 int8 NULL, -- 二级组织机构ID
	organization_name2 varchar(200) DEFAULT NULL::character varying NULL, -- 二级组织机构名称
	organization_id3 int8 NOT NULL, -- 三级组织机构ID
	organization_name3 varchar(200) NOT NULL, -- 三级组织机构名称
	organization_code3 varchar(100) DEFAULT NULL::character varying NULL, -- 三级组织机构编码
	province_code varchar(20) DEFAULT NULL::character varying NULL, -- 省份编码
	province varchar(50) DEFAULT NULL::character varying NULL, -- 省份名称
	device_count int4 DEFAULT 0 NULL, -- 设备数量
	gpu_count int4 DEFAULT 0 NULL, -- GPU总数
	avg_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU平均使用率(%)
	avg_memory_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 显存平均使用率(%)
	max_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU最大使用率(%)
	min_gpu_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- GPU最小使用率(%)
	latest_collection_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 最新采集时间
	summary_time timestamp(0) NOT NULL, -- 汇总时间
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	CONSTRAINT org_gpu_usage_summary_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX org_gpu_usage_summary_idx_organization_id1 ON org_gpu_usage_summary USING btree (organization_id1) TABLESPACE pg_default;
CREATE INDEX org_gpu_usage_summary_idx_organization_id2 ON org_gpu_usage_summary USING btree (organization_id2) TABLESPACE pg_default;
CREATE INDEX org_gpu_usage_summary_idx_organization_id3 ON org_gpu_usage_summary USING btree (organization_id3) TABLESPACE pg_default;
CREATE INDEX org_gpu_usage_summary_idx_province_code ON org_gpu_usage_summary USING btree (province_code) TABLESPACE pg_default;
CREATE INDEX org_gpu_usage_summary_idx_summary_time ON org_gpu_usage_summary USING btree (summary_time) TABLESPACE pg_default;
CREATE INDEX uk_org_summary_time ON org_gpu_usage_summary USING btree (organization_id3, summary_time) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.org_gpu_usage_summary.id IS '主键ID';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_id1 IS '一级组织机构ID';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_name1 IS '一级组织机构名称';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_id2 IS '二级组织机构ID';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_name2 IS '二级组织机构名称';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_id3 IS '三级组织机构ID';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_name3 IS '三级组织机构名称';
COMMENT ON COLUMN public.org_gpu_usage_summary.organization_code3 IS '三级组织机构编码';
COMMENT ON COLUMN public.org_gpu_usage_summary.province_code IS '省份编码';
COMMENT ON COLUMN public.org_gpu_usage_summary.province IS '省份名称';
COMMENT ON COLUMN public.org_gpu_usage_summary.device_count IS '设备数量';
COMMENT ON COLUMN public.org_gpu_usage_summary.gpu_count IS 'GPU总数';
COMMENT ON COLUMN public.org_gpu_usage_summary.avg_gpu_usage_rate IS 'GPU平均使用率(%)';
COMMENT ON COLUMN public.org_gpu_usage_summary.avg_memory_usage_rate IS '显存平均使用率(%)';
COMMENT ON COLUMN public.org_gpu_usage_summary.max_gpu_usage_rate IS 'GPU最大使用率(%)';
COMMENT ON COLUMN public.org_gpu_usage_summary.min_gpu_usage_rate IS 'GPU最小使用率(%)';
COMMENT ON COLUMN public.org_gpu_usage_summary.latest_collection_time IS '最新采集时间';
COMMENT ON COLUMN public.org_gpu_usage_summary.summary_time IS '汇总时间';
COMMENT ON COLUMN public.org_gpu_usage_summary.create_time IS '创建时间';
COMMENT ON COLUMN public.org_gpu_usage_summary.update_time IS '更新时间';


-- public.organization definition

-- Drop table

-- DROP TABLE organization;

CREATE TABLE organization (
	id bigserial NOT NULL, -- 组织ID
	parent_id int8 DEFAULT 0::bigint NULL, -- 父组织ID
	"name" varchar(100) NOT NULL, -- 组织名称
	code varchar(50) DEFAULT NULL::character varying NULL, -- 组织编码
	"type" int2 DEFAULT 1::smallint NULL, -- 组织类型: 1-公司 2-部门 3-小组
	sort int4 DEFAULT 0 NULL, -- 显示顺序
	leader varchar(50) DEFAULT NULL::character varying NULL, -- 负责人
	phone varchar(20) DEFAULT NULL::character varying NULL, -- 联系电话
	email varchar(100) DEFAULT NULL::character varying NULL, -- 邮箱
	address varchar(255) DEFAULT NULL::character varying NULL, -- 地址
	status int2 DEFAULT 1::smallint NULL, -- 状态: 0-禁用 1-正常
	remark varchar(500) DEFAULT NULL::character varying NULL, -- 备注
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by varchar(50) DEFAULT NULL::character varying NULL, -- 创建人
	update_by varchar(50) DEFAULT NULL::character varying NULL, -- 更新人
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	"version" int4 DEFAULT 0 NULL, -- 版本号
	province_code varchar(30) DEFAULT NULL::character varying NULL, -- 省份编码
	province varchar(30) DEFAULT NULL::character varying NULL, -- 省份
	CONSTRAINT organization_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX organization_idx_code ON organization USING btree (code) TABLESPACE pg_default;
CREATE INDEX organization_idx_deleted ON organization USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX organization_idx_parent_id ON organization USING btree (parent_id) TABLESPACE pg_default;
CREATE INDEX organization_idx_status ON organization USING btree (status) TABLESPACE pg_default;
CREATE INDEX organization_province_code_idx ON organization USING btree (province_code, province) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.organization.id IS '组织ID';
COMMENT ON COLUMN public.organization.parent_id IS '父组织ID';
COMMENT ON COLUMN public.organization."name" IS '组织名称';
COMMENT ON COLUMN public.organization.code IS '组织编码';
COMMENT ON COLUMN public.organization."type" IS '组织类型: 1-公司 2-部门 3-小组';
COMMENT ON COLUMN public.organization.sort IS '显示顺序';
COMMENT ON COLUMN public.organization.leader IS '负责人';
COMMENT ON COLUMN public.organization.phone IS '联系电话';
COMMENT ON COLUMN public.organization.email IS '邮箱';
COMMENT ON COLUMN public.organization.address IS '地址';
COMMENT ON COLUMN public.organization.status IS '状态: 0-禁用 1-正常';
COMMENT ON COLUMN public.organization.remark IS '备注';
COMMENT ON COLUMN public.organization.create_time IS '创建时间';
COMMENT ON COLUMN public.organization.update_time IS '更新时间';
COMMENT ON COLUMN public.organization.create_by IS '创建人';
COMMENT ON COLUMN public.organization.update_by IS '更新人';
COMMENT ON COLUMN public.organization.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.organization."version" IS '版本号';
COMMENT ON COLUMN public.organization.province_code IS '省份编码';
COMMENT ON COLUMN public.organization.province IS '省份';


-- public.schedule_job definition

-- Drop table

-- DROP TABLE schedule_job;

CREATE TABLE schedule_job (
	id bigserial NOT NULL, -- 任务ID
	job_name varchar(100) NOT NULL, -- 任务名称
	job_group varchar(50) DEFAULT 'DEFAULT'::character varying NULL, -- 任务组名
	bean_name varchar(100) NOT NULL, -- Bean名称
	method_name varchar(100) NOT NULL, -- 方法名称
	method_params varchar(500) DEFAULT NULL::character varying NULL, -- 方法参数
	cron_expression varchar(100) NOT NULL, -- Cron表达式
	status int2 DEFAULT 0::smallint NULL, -- 任务状态: 0-暂停 1-运行中
	concurrent int2 DEFAULT 0::smallint NULL, -- 是否并发执行: 0-禁止 1-允许
	misfire_policy int2 DEFAULT 1::smallint NULL, -- 错过执行策略: 1-立即执行 2-执行一次 3-放弃执行
	description varchar(500) DEFAULT NULL::character varying NULL, -- 任务描述
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by varchar(50) DEFAULT NULL::character varying NULL, -- 创建人
	update_by varchar(50) DEFAULT NULL::character varying NULL, -- 更新人
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	CONSTRAINT schedule_job_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX schedule_job_idx_deleted ON schedule_job USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX schedule_job_idx_job_name ON schedule_job USING btree (job_name) TABLESPACE pg_default;
CREATE INDEX schedule_job_idx_status ON schedule_job USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.schedule_job.id IS '任务ID';
COMMENT ON COLUMN public.schedule_job.job_name IS '任务名称';
COMMENT ON COLUMN public.schedule_job.job_group IS '任务组名';
COMMENT ON COLUMN public.schedule_job.bean_name IS 'Bean名称';
COMMENT ON COLUMN public.schedule_job.method_name IS '方法名称';
COMMENT ON COLUMN public.schedule_job.method_params IS '方法参数';
COMMENT ON COLUMN public.schedule_job.cron_expression IS 'Cron表达式';
COMMENT ON COLUMN public.schedule_job.status IS '任务状态: 0-暂停 1-运行中';
COMMENT ON COLUMN public.schedule_job.concurrent IS '是否并发执行: 0-禁止 1-允许';
COMMENT ON COLUMN public.schedule_job.misfire_policy IS '错过执行策略: 1-立即执行 2-执行一次 3-放弃执行';
COMMENT ON COLUMN public.schedule_job.description IS '任务描述';
COMMENT ON COLUMN public.schedule_job.create_time IS '创建时间';
COMMENT ON COLUMN public.schedule_job.update_time IS '更新时间';
COMMENT ON COLUMN public.schedule_job.create_by IS '创建人';
COMMENT ON COLUMN public.schedule_job.update_by IS '更新人';
COMMENT ON COLUMN public.schedule_job.deleted IS '删除标志: 0-未删除 1-已删除';


-- public.schedule_job_log definition

-- Drop table

-- DROP TABLE schedule_job_log;

CREATE TABLE schedule_job_log (
	id bigserial NOT NULL, -- 日志ID
	job_id int8 NOT NULL, -- 任务ID
	job_name varchar(100) NOT NULL, -- 任务名称
	job_group varchar(50) DEFAULT NULL::character varying NULL, -- 任务组名
	bean_name varchar(100) DEFAULT NULL::character varying NULL, -- Bean名称
	method_name varchar(100) DEFAULT NULL::character varying NULL, -- 方法名称
	method_params varchar(500) DEFAULT NULL::character varying NULL, -- 方法参数
	status int2 DEFAULT 0::smallint NULL, -- 执行状态: 0-失败 1-成功
	start_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 开始时间
	end_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 结束时间
	execute_time int8 NULL, -- 执行时长(毫秒)
	exception_info text NULL, -- 异常信息
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT schedule_job_log_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX schedule_job_log_idx_create_time ON schedule_job_log USING btree (create_time) TABLESPACE pg_default;
CREATE INDEX schedule_job_log_idx_job_id ON schedule_job_log USING btree (job_id) TABLESPACE pg_default;
CREATE INDEX schedule_job_log_idx_status ON schedule_job_log USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.schedule_job_log.id IS '日志ID';
COMMENT ON COLUMN public.schedule_job_log.job_id IS '任务ID';
COMMENT ON COLUMN public.schedule_job_log.job_name IS '任务名称';
COMMENT ON COLUMN public.schedule_job_log.job_group IS '任务组名';
COMMENT ON COLUMN public.schedule_job_log.bean_name IS 'Bean名称';
COMMENT ON COLUMN public.schedule_job_log.method_name IS '方法名称';
COMMENT ON COLUMN public.schedule_job_log.method_params IS '方法参数';
COMMENT ON COLUMN public.schedule_job_log.status IS '执行状态: 0-失败 1-成功';
COMMENT ON COLUMN public.schedule_job_log.start_time IS '开始时间';
COMMENT ON COLUMN public.schedule_job_log.end_time IS '结束时间';
COMMENT ON COLUMN public.schedule_job_log.execute_time IS '执行时长(毫秒)';
COMMENT ON COLUMN public.schedule_job_log.exception_info IS '异常信息';
COMMENT ON COLUMN public.schedule_job_log.create_time IS '创建时间';


-- public.statistics_data definition

-- Drop table

-- DROP TABLE statistics_data;

CREATE TABLE statistics_data (
	id bigserial NOT NULL, -- 主键ID
	stat_time timestamp(0) NOT NULL, -- 统计时间点
	stat_date timestamp(0) NOT NULL, -- 统计日期
	stat_hour int2 NOT NULL, -- 统计小时(0-23)
	stat_minute int2 NULL, -- 统计分钟(0-59)
	stat_type varchar(20) DEFAULT 'ALL'::character varying NULL, -- 统计类型：ALL-全国, LOCAL-地方厅 MINISTRY-部机关
	device_id int8 NULL, -- 设备id
	device_code varchar(30) DEFAULT NULL::character varying NULL,
	device_total int4 DEFAULT 0 NULL, -- 设备总数
	memory_total_gb numeric(15, 2) DEFAULT 0.00 NULL, -- 显存总量(GB)
	memory_used_gb numeric(15, 2) DEFAULT 0.00 NULL, -- 已使用显存(GB)
	memory_free_gb numeric(15, 2) DEFAULT 0.00 NULL, -- 空闲显存(GB)
	memory_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 显存使用率(%)
	compute_total_tflops numeric(15, 2) DEFAULT 0.00 NULL, -- 算力总量(TFLOPS)
	compute_used_tflops numeric(15, 2) DEFAULT 0.00 NULL, -- 已使用算力(TFLOPS)
	compute_free_tflops numeric(15, 2) DEFAULT 0.00 NULL, -- 空闲算力(TFLOPS)
	avg_gpu_utilization numeric(5, 2) DEFAULT 0.00 NULL, -- 平均GPU核心利用率（百分比）
	avg_temperature numeric(5, 2) DEFAULT NULL::numeric NULL, -- GPU温度
	virtual_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- 内存使用率
	cpu_percent numeric(5, 2) DEFAULT NULL::numeric NULL, -- cpu使用率
	overall_usage_rate numeric(5, 2) DEFAULT 0.00 NULL, -- 综合使用率(%)
	gpu_total_count int4 DEFAULT 0 NULL, -- GPU总数
	task_running_count int4 DEFAULT 0 NULL, -- 运行中任务数
	task_pending_count int4 DEFAULT 0 NULL, -- 等待中任务数
	task_completed_count int4 DEFAULT 0 NULL, -- 已完成任务数
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志(0-未删除,1-已删除)
	CONSTRAINT statistics_data_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX idx_stat_query ON statistics_data USING btree (stat_date, stat_hour, stat_type, device_id) TABLESPACE pg_default;
CREATE INDEX statistics_data_idx_stat_date ON statistics_data USING btree (stat_date) TABLESPACE pg_default;
CREATE INDEX statistics_data_idx_stat_date_hour ON statistics_data USING btree (stat_date, stat_hour) TABLESPACE pg_default;
CREATE INDEX statistics_data_idx_stat_query ON statistics_data USING btree (stat_date, stat_hour, stat_type, device_id) TABLESPACE pg_default;
CREATE INDEX statistics_data_idx_stat_time ON statistics_data USING btree (stat_time) TABLESPACE pg_default;
CREATE INDEX statistics_data_idx_stat_type ON statistics_data USING btree (stat_type) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.statistics_data.id IS '主键ID';
COMMENT ON COLUMN public.statistics_data.stat_time IS '统计时间点';
COMMENT ON COLUMN public.statistics_data.stat_date IS '统计日期';
COMMENT ON COLUMN public.statistics_data.stat_hour IS '统计小时(0-23)';
COMMENT ON COLUMN public.statistics_data.stat_minute IS '统计分钟(0-59)';
COMMENT ON COLUMN public.statistics_data.stat_type IS '统计类型：ALL-全国, LOCAL-地方厅 MINISTRY-部机关';
COMMENT ON COLUMN public.statistics_data.device_id IS '设备id';
COMMENT ON COLUMN public.statistics_data.device_total IS '设备总数';
COMMENT ON COLUMN public.statistics_data.memory_total_gb IS '显存总量(GB)';
COMMENT ON COLUMN public.statistics_data.memory_used_gb IS '已使用显存(GB)';
COMMENT ON COLUMN public.statistics_data.memory_free_gb IS '空闲显存(GB)';
COMMENT ON COLUMN public.statistics_data.memory_usage_rate IS '显存使用率(%)';
COMMENT ON COLUMN public.statistics_data.compute_total_tflops IS '算力总量(TFLOPS)';
COMMENT ON COLUMN public.statistics_data.compute_used_tflops IS '已使用算力(TFLOPS)';
COMMENT ON COLUMN public.statistics_data.compute_free_tflops IS '空闲算力(TFLOPS)';
COMMENT ON COLUMN public.statistics_data.avg_gpu_utilization IS '平均GPU核心利用率（百分比）';
COMMENT ON COLUMN public.statistics_data.avg_temperature IS 'GPU温度';
COMMENT ON COLUMN public.statistics_data.virtual_percent IS '内存使用率';
COMMENT ON COLUMN public.statistics_data.cpu_percent IS 'cpu使用率';
COMMENT ON COLUMN public.statistics_data.overall_usage_rate IS '综合使用率(%)';
COMMENT ON COLUMN public.statistics_data.gpu_total_count IS 'GPU总数';
COMMENT ON COLUMN public.statistics_data.task_running_count IS '运行中任务数';
COMMENT ON COLUMN public.statistics_data.task_pending_count IS '等待中任务数';
COMMENT ON COLUMN public.statistics_data.task_completed_count IS '已完成任务数';
COMMENT ON COLUMN public.statistics_data.create_time IS '创建时间';
COMMENT ON COLUMN public.statistics_data.update_time IS '更新时间';
COMMENT ON COLUMN public.statistics_data.deleted IS '删除标志(0-未删除,1-已删除)';


-- public.sys_menu definition

-- Drop table

-- DROP TABLE sys_menu;

CREATE TABLE sys_menu (
	id bigserial NOT NULL, -- 菜单ID
	parent_id int8 DEFAULT 0::bigint NULL, -- 父菜单ID
	menu_name varchar(50) NOT NULL, -- 菜单名称
	menu_type bpchar(1) DEFAULT 'M'::bpchar NULL, -- 菜单类型: M-目录 C-菜单 F-按钮
	"path" varchar(200) DEFAULT NULL::character varying NULL, -- 路由地址
	component varchar(255) DEFAULT NULL::character varying NULL, -- 组件路径
	"permission" varchar(100) DEFAULT NULL::character varying NULL, -- 权限标识
	icon varchar(100) DEFAULT NULL::character varying NULL, -- 菜单图标
	sort int4 DEFAULT 0 NULL, -- 显示顺序
	is_frame int2 DEFAULT 0::smallint NULL, -- 是否外链: 0-否 1-是
	is_cache int2 DEFAULT 0::smallint NULL, -- 是否缓存: 0-不缓存 1-缓存
	visible int2 DEFAULT 1::smallint NULL, -- 菜单状态: 0-隐藏 1-显示
	status int2 DEFAULT 1::smallint NULL, -- 状态: 0-禁用 1-正常
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by int8 NULL, -- 创建人ID
	update_by int8 NULL, -- 更新人ID
	remark varchar(500) DEFAULT NULL::character varying NULL, -- 备注
	CONSTRAINT sys_menu_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX sys_menu_idx_deleted ON sys_menu USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX sys_menu_idx_parent_id ON sys_menu USING btree (parent_id) TABLESPACE pg_default;
CREATE INDEX sys_menu_idx_status ON sys_menu USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.sys_menu.id IS '菜单ID';
COMMENT ON COLUMN public.sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN public.sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN public.sys_menu.menu_type IS '菜单类型: M-目录 C-菜单 F-按钮';
COMMENT ON COLUMN public.sys_menu."path" IS '路由地址';
COMMENT ON COLUMN public.sys_menu.component IS '组件路径';
COMMENT ON COLUMN public.sys_menu."permission" IS '权限标识';
COMMENT ON COLUMN public.sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN public.sys_menu.sort IS '显示顺序';
COMMENT ON COLUMN public.sys_menu.is_frame IS '是否外链: 0-否 1-是';
COMMENT ON COLUMN public.sys_menu.is_cache IS '是否缓存: 0-不缓存 1-缓存';
COMMENT ON COLUMN public.sys_menu.visible IS '菜单状态: 0-隐藏 1-显示';
COMMENT ON COLUMN public.sys_menu.status IS '状态: 0-禁用 1-正常';
COMMENT ON COLUMN public.sys_menu.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.sys_menu.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_menu.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_menu.create_by IS '创建人ID';
COMMENT ON COLUMN public.sys_menu.update_by IS '更新人ID';
COMMENT ON COLUMN public.sys_menu.remark IS '备注';


-- public.sys_operation_log definition

-- Drop table

-- DROP TABLE sys_operation_log;

CREATE TABLE sys_operation_log (
	id bigserial NOT NULL, -- 日志ID
	"module" varchar(50) DEFAULT NULL::character varying NULL, -- 操作模块
	operation_type varchar(20) DEFAULT NULL::character varying NULL, -- 操作类型
	description varchar(200) DEFAULT NULL::character varying NULL, -- 操作描述
	"method" varchar(200) DEFAULT NULL::character varying NULL, -- 方法名称
	request_url varchar(500) DEFAULT NULL::character varying NULL, -- 请求URL
	request_method varchar(10) DEFAULT NULL::character varying NULL, -- 请求方式: GET POST PUT DELETE
	request_data text NULL, -- 请求参数
	response_data text NULL, -- 响应数据
	operator_name varchar(50) DEFAULT NULL::character varying NULL, -- 操作人用户名
	ip_address varchar(128) DEFAULT NULL::character varying NULL, -- 操作IP地址
	user_agent varchar(500) DEFAULT NULL::character varying NULL, -- 用户代理
	status int2 DEFAULT 1::smallint NULL, -- 执行状态: 0-失败 1-成功
	error_msg varchar(2000) DEFAULT NULL::character varying NULL, -- 错误消息
	execute_time int4 NULL, -- 执行时间(毫秒)
	operate_time timestamp(0) DEFAULT NULL::timestamp without time zone NULL, -- 操作时间
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	CONSTRAINT sys_operation_log_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX sys_operation_log_idx_operate_time ON sys_operation_log USING btree (operate_time) TABLESPACE pg_default;
CREATE INDEX sys_operation_log_idx_operation_type ON sys_operation_log USING btree (operation_type) TABLESPACE pg_default;
CREATE INDEX sys_operation_log_idx_operator_name ON sys_operation_log USING btree (operator_name) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.sys_operation_log.id IS '日志ID';
COMMENT ON COLUMN public.sys_operation_log."module" IS '操作模块';
COMMENT ON COLUMN public.sys_operation_log.operation_type IS '操作类型';
COMMENT ON COLUMN public.sys_operation_log.description IS '操作描述';
COMMENT ON COLUMN public.sys_operation_log."method" IS '方法名称';
COMMENT ON COLUMN public.sys_operation_log.request_url IS '请求URL';
COMMENT ON COLUMN public.sys_operation_log.request_method IS '请求方式: GET POST PUT DELETE';
COMMENT ON COLUMN public.sys_operation_log.request_data IS '请求参数';
COMMENT ON COLUMN public.sys_operation_log.response_data IS '响应数据';
COMMENT ON COLUMN public.sys_operation_log.operator_name IS '操作人用户名';
COMMENT ON COLUMN public.sys_operation_log.ip_address IS '操作IP地址';
COMMENT ON COLUMN public.sys_operation_log.user_agent IS '用户代理';
COMMENT ON COLUMN public.sys_operation_log.status IS '执行状态: 0-失败 1-成功';
COMMENT ON COLUMN public.sys_operation_log.error_msg IS '错误消息';
COMMENT ON COLUMN public.sys_operation_log.execute_time IS '执行时间(毫秒)';
COMMENT ON COLUMN public.sys_operation_log.operate_time IS '操作时间';
COMMENT ON COLUMN public.sys_operation_log.create_time IS '创建时间';


-- public.sys_role definition

-- Drop table

-- DROP TABLE sys_role;

CREATE TABLE sys_role (
	id bigserial NOT NULL, -- 角色ID
	role_code varchar(50) NOT NULL, -- 角色编码
	role_name varchar(50) NOT NULL, -- 角色名称
	sort int4 DEFAULT 0 NULL, -- 显示顺序
	status int2 DEFAULT 1::smallint NULL, -- 状态: 0-禁用 1-正常
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by int8 NULL, -- 创建人ID
	update_by int8 NULL, -- 更新人ID
	remark varchar(500) DEFAULT NULL::character varying NULL, -- 备注
	CONSTRAINT sys_role_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX sys_role_idx_deleted ON sys_role USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX sys_role_idx_role_code ON sys_role USING btree (role_code) TABLESPACE pg_default;
CREATE INDEX sys_role_idx_status ON sys_role USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.sys_role.id IS '角色ID';
COMMENT ON COLUMN public.sys_role.role_code IS '角色编码';
COMMENT ON COLUMN public.sys_role.role_name IS '角色名称';
COMMENT ON COLUMN public.sys_role.sort IS '显示顺序';
COMMENT ON COLUMN public.sys_role.status IS '状态: 0-禁用 1-正常';
COMMENT ON COLUMN public.sys_role.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.sys_role.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_role.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_role.create_by IS '创建人ID';
COMMENT ON COLUMN public.sys_role.update_by IS '更新人ID';
COMMENT ON COLUMN public.sys_role.remark IS '备注';


-- public.sys_role_menu definition

-- Drop table

-- DROP TABLE sys_role_menu;

CREATE TABLE sys_role_menu (
	role_id int8 NOT NULL, -- 角色ID
	menu_id int8 NOT NULL, -- 菜单ID
	CONSTRAINT sys_role_menu_pkey PRIMARY KEY (role_id, menu_id)
)
WITH (
	orientation=row,
	compression=no
);

-- Column comments

COMMENT ON COLUMN public.sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN public.sys_role_menu.menu_id IS '菜单ID';


-- public.sys_user definition

-- Drop table

-- DROP TABLE sys_user;

CREATE TABLE sys_user (
	id bigserial NOT NULL, -- 用户ID
	username varchar(50) NOT NULL, -- 用户名
	nickname varchar(50) DEFAULT NULL::character varying NULL, -- 昵称
	"password" varchar(255) NOT NULL, -- 密码(加密)
	email varchar(100) DEFAULT NULL::character varying NULL, -- 邮箱
	phone varchar(20) DEFAULT NULL::character varying NULL, -- 手机号
	gender int2 DEFAULT 0::smallint NULL, -- 性别: 0-未知 1-男 2-女
	avatar varchar(255) DEFAULT NULL::character varying NULL, -- 头像URL
	organization_id int8 NULL, -- 所属组织ID
	status int2 DEFAULT 1::smallint NULL, -- 状态: 0-禁用 1-正常
	deleted int2 DEFAULT 0::smallint NULL, -- 删除标志: 0-未删除 1-已删除
	create_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 创建时间
	update_time timestamp(0) DEFAULT pg_systimestamp() NULL, -- 更新时间
	create_by int8 NULL, -- 创建人ID
	update_by int8 NULL, -- 更新人ID
	remark varchar(500) DEFAULT NULL::character varying NULL, -- 备注
	CONSTRAINT sys_user_pkey PRIMARY KEY (id)
)
WITH (
	orientation=row,
	compression=no
);
CREATE INDEX sys_user_idx_deleted ON sys_user USING btree (deleted) TABLESPACE pg_default;
CREATE INDEX sys_user_idx_organization_id ON sys_user USING btree (organization_id) TABLESPACE pg_default;
CREATE INDEX sys_user_idx_status ON sys_user USING btree (status) TABLESPACE pg_default;

-- Column comments

COMMENT ON COLUMN public.sys_user.id IS '用户ID';
COMMENT ON COLUMN public.sys_user.username IS '用户名';
COMMENT ON COLUMN public.sys_user.nickname IS '昵称';
COMMENT ON COLUMN public.sys_user."password" IS '密码(加密)';
COMMENT ON COLUMN public.sys_user.email IS '邮箱';
COMMENT ON COLUMN public.sys_user.phone IS '手机号';
COMMENT ON COLUMN public.sys_user.gender IS '性别: 0-未知 1-男 2-女';
COMMENT ON COLUMN public.sys_user.avatar IS '头像URL';
COMMENT ON COLUMN public.sys_user.organization_id IS '所属组织ID';
COMMENT ON COLUMN public.sys_user.status IS '状态: 0-禁用 1-正常';
COMMENT ON COLUMN public.sys_user.deleted IS '删除标志: 0-未删除 1-已删除';
COMMENT ON COLUMN public.sys_user.create_time IS '创建时间';
COMMENT ON COLUMN public.sys_user.update_time IS '更新时间';
COMMENT ON COLUMN public.sys_user.create_by IS '创建人ID';
COMMENT ON COLUMN public.sys_user.update_by IS '更新人ID';
COMMENT ON COLUMN public.sys_user.remark IS '备注';


-- public.sys_user_role definition

-- Drop table

-- DROP TABLE sys_user_role;

CREATE TABLE sys_user_role (
	user_id int8 NOT NULL, -- 用户ID
	role_id int8 NOT NULL, -- 角色ID
	CONSTRAINT sys_user_role_pkey PRIMARY KEY (user_id, role_id)
)
WITH (
	orientation=row,
	compression=no
);

-- Column comments

COMMENT ON COLUMN public.sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN public.sys_user_role.role_id IS '角色ID';