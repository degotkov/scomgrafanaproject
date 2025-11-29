WITH BaseSet AS (
    SELECT 
        PerformanceRuleInstanceRowId, 
        ManagedEntityRowId, 
        MAX(DateTime) AS DateTime
    FROM 
        Perf.vPerfRaw
    WHERE 
        DateTime > DATEADD(MINUTE, -10, GETDATE())
    GROUP BY 
        PerformanceRuleInstanceRowId, ManagedEntityRowId
)
SELECT
    vme.Path, 
    SUBSTRING(vme.Path, CHARINDEX('.', vme.Path) + 1, LEN(vme.Path)) AS Domain,
    vpr.ObjectName AS Object, 
    vpr.CounterName AS Counter, 
    vpri.InstanceName AS Instance, 
    ROUND(pvpr.SampleValue, 0) AS Value,
FROM 
    Perf.vPerfRaw AS pvpr
    INNER JOIN dbo.vManagedEntity AS vme 
        ON pvpr.ManagedEntityRowId = vme.ManagedEntityRowId
    INNER JOIN dbo.vPerformanceRuleInstance AS vpri 
        ON pvpr.PerformanceRuleInstanceRowId = vpri.PerformanceRuleInstanceRowId
    INNER JOIN dbo.vPerformanceRule AS vpr 
        ON vpr.RuleRowId = vpri.RuleRowId
    INNER JOIN BaseSet 
        ON pvpr.ManagedEntityRowId = BaseSet.ManagedEntityRowId 
        AND pvpr.PerformanceRuleInstanceRowId = BaseSet.PerformanceRuleInstanceRowId 
        AND pvpr.DateTime = BaseSet.DateTime
WHERE 
    (
        vpr.ObjectName = 'Processor Information' 
        OR vpr.ObjectName = 'System'
        OR vpr.ObjectName = 'Memory'
        OR vpr.ObjectName = 'LogicalDisk'
        OR vpr.ObjectName = 'Network Adapter'
    )
    AND pvpr.DateTime > DATEADD(MINUTE, -10, GETDATE())
