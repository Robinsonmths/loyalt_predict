SELECT
    dtRef,
    descLifeCycle,
    count(*) AS qtdClientes
FROM
    life_cycle
WHERE
    descLifeCycle <> '05-Zumbi'
GROUP BY
    dtRef,
    descLifeCycle
ORDER BY
    dtRef,
    descLifeCycle