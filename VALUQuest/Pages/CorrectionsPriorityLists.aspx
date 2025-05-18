<%@ Page Title="" Language="C#" MasterPageFile="~/Template/ValuMaster.Master" AutoEventWireup="true" CodeBehind="CorrectionsPriorityLists.aspx.cs" Inherits="VALUQuest.Pages.CorrectionsPriorityLists" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- <link href="https://unpkg.com/@hyper-ui/core@1.2.3/dist/hyper.min.css" rel="stylesheet" /> -->
    <script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>

    <style>
        :root {
            --ct-font-sans-serif: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        html, body {
            font-family: var(--ct-font-sans-serif);
        }

        .container {
            display: flex;
            flex-direction: row;
            height: 75vh;
            gap: 1rem;
            padding: 1rem;
            box-sizing: border-box;
        }

        .left, .right {
            flex: 1;
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 1rem;
            background: white;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        .list-title {
            font-weight: bold;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            font-size: 1.1rem;
        }

        .priority-list {
            border: 2px solid #008080;
            border-radius: 8px;
            padding: 0.8rem;
            margin-bottom: 1.5rem;
            background-color: #eefdfd;
        }

        .priority-rows {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .priority-row {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
            background: #f4f4f4;
            border: 1px dashed #aaa;
            border-radius: 6px;
            padding: 0.5rem;
        }

        .row-line {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .item {
            padding: 0.4rem 0.6rem;
            background: #fff;
            border: 1px solid #999;
            border-radius: 4px;
            display: flex;
            align-items: center;
            gap: 0.3rem;
            cursor: grab;
            min-width: 100px;
        }

        .item .delete-btn {
            color: red;
            font-weight: bold;
            cursor: pointer;
            border: 1px solid red;
            border-radius: 4px;
            padding: 0 5px;
        }

        .remove-list {
            float: right;
            background: none;
            border: 2px solid red;
            color: red;
            padding: 2px 6px;
            font-weight: bold;
            border-radius: 4px;
            cursor: pointer;
        }

        .add-row-btn {
            margin-top: 0.5rem;
            font-size: 0.85rem;
        }

        .create-btn {
            margin-bottom: 1rem;
        }

        .connector-select {
            padding: 0.3rem;
            border: 1px solid #aaa;
            border-radius: 4px;
            background: #eee;
            font-weight: bold;
        }

        .priority-list.collapsed .priority-rows {
            display: none;
        }
        .priority-list.active {
            border-color: #2e8b57; /* verde */
            background-color: #e8fce8;
        }

        .priority-list.inactive {
            border-color: #b22222; /* rosso */
            background-color: #fde8e8;
        }
        .priority-list.draft {
            border: 2px solid #3399ff;
            background-color: #e6f4ff;
        }.new-list-highlight {
            border: 2px solid #3399ff !important;
            background-color: #e6f4ff !important;
            transition: background-color 1s, border 1s;
        }

    </style>

    <form id="form1" runat="server">
        <div class="container">
            <div class="left">
                <button type="button" class="create-btn hyper-btn hyper-btn-secondary" onclick="createList()">+ Nuova Lista</button>
                <div id="listsContainer"></div>
            </div>

            <div class="right">
                <div class="list-title">Tutte le Correzioni</div>
                <div id="allItems" class="priority-row">
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hiddenJsonData" runat="server" />
    </form>

    <script>

        let listCounter = 1;

        function loadCorrections() {
            return fetch('CorrectionsPriorityLists.aspx/getCorrectionsWithConditions', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
                .then(res => res.json())
                .then(res => {
                    let items = res.d;
                    if (typeof items === 'string') items = JSON.parse(items);
                    if (!Array.isArray(items)) items = [items];

                    const container = document.getElementById('allItems');
                    container.innerHTML = '';

                    items.forEach(corr => {
                        const div = document.createElement('div');
                        div.className = 'item';
                        div.setAttribute('draggable', 'true');
                        div.setAttribute('data-id', corr.correctionId);
                        div.setAttribute('title', corr.message || corr.notes || '');

                        const valueFormatted = `${corr.valueToAdd > 0 ? '+' : ''}${corr.valueToAdd}`;
                        const valueColor = corr.valueToAdd > 0 ? 'green' : (corr.valueToAdd < 0 ? 'red' : 'black');
                        div.innerHTML = `${corr.correctionName} <span style="color:${valueColor}; font-weight:bold;">(${valueFormatted})</span>`;

                        container.appendChild(div);
                    });

                    new Sortable(container, {
                        group: { name: 'shared', pull: 'clone', put: false },
                        animation: 150,
                        sort: false
                    });
                })
                .catch(err => {
                    console.error("❌ Errore caricamento correzioni:", err);
                });
        }

        function loadSavedLists() {
            fetch('CorrectionsPriorityLists.aspx/LoadAllPriorityLists', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            })
                .then(res => res.json())
                .then(res => {
                    const lists = res.d || [];
                    console.log("Liste ricevute:", lists);

                    lists.forEach(list => {
                        createListFromDB(list);
                    });
                })
                .catch(err => console.error("Errore caricamento liste:", err));
        }

        function createListFromDB(list) {
            const listId = `priority-${list.ListId}`;
            const wrapper = document.createElement('div');
            const statusClass = list.IsActive ? 'active' : 'inactive';
            wrapper.className = `priority-list ${statusClass}`;
            wrapper.setAttribute('data-listid', list.ListId);

            const collapsed = true; // <-- puoi cambiare in false se vuoi il contrario

            if (collapsed) {
                setTimeout(() => {
                    const rowContainer = wrapper.querySelector('.priority-rows');
                    const arrow = wrapper.querySelector('.arrow');
                    if (rowContainer && arrow) {
                        rowContainer.style.display = 'none';
                        arrow.textContent = '＋';
                        arrow.title = 'Expand';
                    }
                }, 0);
            }

            wrapper.innerHTML = `
                <div class="list-title" onclick="toggleList(this)" style="cursor: pointer;" title="Collapse">
                    <button type="button" class="arrow hyper-btn hyper-btn-sm" style="width: 28px; height: 28px; padding: 0; margin-right: 5px;">−</button>
                    <span class="editable-title" ondblclick="toggleTitleEdit(this)">${list.ListName}</span>
                    <input type="text" class="title-input" style="display:none;" onblur="confirmTitleEdit(this)" />
                    <button class="remove-list" onclick="event.stopPropagation(); confirmDeleteList(this)">X</button>
                </div>
                <div class="priority-rows" id="${listId}" style="display: flex;"></div>
                <div style="margin-top: 0.5rem; display: flex; gap: 0.5rem;">
                    <button type="button" class="add-row-btn hyper-btn hyper-btn-sm" onclick="addRow('${listId}')">+ Nuovo elemento</button>
                    <button type="button" class="hyper-btn hyper-btn-primary hyper-btn-sm" onclick="saveSingleList(this)">Salva lista</button>
                    <button type="button" class="hyper-btn hyper-btn-sm toggle-status-btn" onclick="toggleListStatus(this)">${list.IsActive ? 'Disattiva' : 'Attiva'}</button>
                </div>
            `;

            document.getElementById('listsContainer').appendChild(wrapper);

            // Collassa solo liste caricate da DB
            const rowContainer = wrapper.querySelector('.priority-rows');
            const arrow = wrapper.querySelector('.arrow');
            if (rowContainer && arrow) {
                rowContainer.style.display = 'none';
                arrow.textContent = '＋';
                arrow.title = 'Expand';
            }


            list.Rows.forEach(row => {
                const rowContainer = document.createElement('div');
                rowContainer.className = 'priority-row';
                document.getElementById(listId).appendChild(rowContainer);

                row.Corrections.forEach((corr, idx) => {
                    const line = document.createElement('div');
                    line.className = 'row-line';

                    const original = document.querySelector(`#allItems .item[data-id="${corr.CorrectionId}"]`);
                    if (original) {
                        const clone = original.cloneNode(true);
                        clone.querySelectorAll('.delete-btn').forEach(btn => btn.remove());

                        const delBtn = document.createElement('span');
                        delBtn.textContent = 'X';
                        delBtn.className = 'delete-btn';
                        delBtn.onclick = () => {
                            line.remove();
                            updateRow(rowContainer);
                        };
                        clone.appendChild(delBtn);

                        line.appendChild(clone);
                    }

                    if (corr.ConnectorToNext && idx < row.Corrections.length - 1) {
                        const connector = document.createElement('select');
                        connector.className = 'connector-select';
                        connector.innerHTML = `
                    <option value="AND">AND</option>
                    <option value="OR">OR</option>
                `;
                        connector.value = corr.ConnectorToNext;
                        line.appendChild(connector);
                    }

                    rowContainer.appendChild(line);
                });

                // ✅ Rendila modificabile: abilita Sortable per questa riga
                new Sortable(rowContainer, {
                    group: 'shared',
                    animation: 150,
                    sort: true,
                    onAdd: evt => {
                        const clone = evt.item.cloneNode(true);
                        evt.item.remove();
                        clone.querySelectorAll('.delete-btn').forEach(btn => btn.remove());

                        const delBtn = document.createElement('span');
                        delBtn.textContent = 'X';
                        delBtn.className = 'delete-btn';
                        delBtn.onclick = () => {
                            line.remove();
                            updateRow(rowContainer);
                        };
                        clone.appendChild(delBtn);

                        const line = document.createElement('div');
                        line.className = 'row-line';
                        line.appendChild(clone);
                        rowContainer.appendChild(line);

                        updateRow(rowContainer);
                    },
                    onUpdate: () => updateRow(rowContainer),
                    onRemove: () => updateRow(rowContainer)
                });

                updateRow(rowContainer);
            });
        }

        function createList() {
            const listId = `priority-${listCounter}`;
            const wrapper = document.createElement('div');
            wrapper.className = 'priority-list active';
            wrapper.classList.add('new-list-highlight');
            wrapper.scrollIntoView({ behavior: 'smooth', block: 'center' });

            wrapper.innerHTML = `
        <div class="list-title" onclick="toggleList(this)" style="cursor: pointer;" title="Collapse">
            <button type="button" class="arrow hyper-btn hyper-btn-sm" style="width: 28px; height: 28px; padding: 0; margin-right: 5px;">−</button>
            <span class="editable-title" ondblclick="toggleTitleEdit(this)">PRIORITY LIST ${listCounter}</span>
            <input type="text" class="title-input" style="display:none;" onblur="confirmTitleEdit(this)" />
            <button class="remove-list" onclick="event.stopPropagation(); confirmDeleteList(this)">X</button>
        </div>
        <div class="priority-rows" id="${listId}" style="display: flex;"></div>
        <div style="margin-top: 0.5rem; display: flex; gap: 0.5rem;">
            <button type="button" class="add-row-btn hyper-btn hyper-btn-sm" onclick="addRow('${listId}')">+ Nuovo elemento</button>
            <button type="button" class="hyper-btn hyper-btn-primary hyper-btn-sm" onclick="saveSingleList(this)">Salva lista</button>
            <button type="button" class="hyper-btn hyper-btn-sm toggle-status-btn" onclick="toggleListStatus(this)">Disattiva</button>
        </div>`;

            document.getElementById('listsContainer').appendChild(wrapper);
            addRow(listId);
            listCounter++;
        }

        function toggleList(header) {
            const listContainer = header.closest('.priority-list');
            const rows = listContainer.querySelector('.priority-rows');
            const arrow = header.querySelector('.arrow');

            const isCollapsed = rows.style.display === 'none';

            if (isCollapsed) {
                rows.style.display = 'flex';
                arrow.textContent = '−';
                header.title = 'Collapse';
            } else {
                rows.style.display = 'none';
                arrow.textContent = '＋';
                header.title = 'Expand';
            }
        }

        function toggleListStatus(button) {
            const list = button.closest('.priority-list');
            const isActive = list.classList.contains('active');

            if (isActive) {
                list.classList.remove('active');
                list.classList.add('inactive');
                button.textContent = 'Attiva';
            } else {
                list.classList.remove('inactive');
                list.classList.add('active');
                button.textContent = 'Disattiva';
            }
        }

        function toggleTitleEdit(span) {
            const input = span.nextElementSibling;
            input.value = span.textContent.trim();
            span.style.display = 'none';
            input.style.display = 'inline-block';
            input.focus();
        }

        function confirmTitleEdit(input) {
            const span = input.previousElementSibling;
            span.textContent = input.value.trim() || "Senza nome";
            input.style.display = 'none';
            span.style.display = 'inline-block';
        }

        function confirmDeleteList(button) {
            if (!confirm("Confermi di eliminare questa lista?")) return;

            const listElem = button.closest('.priority-list');
            const listIdAttr = listElem.getAttribute('data-listid');

            if (listIdAttr) {
                fetch('CorrectionsPriorityLists.aspx/DeleteList', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ listId: parseInt(listIdAttr) })
                })
                    .then(res => res.json())
                    .then(result => {
                        if (result.d === "OK") {
                            listElem.remove();
                        } else {
                            alert("Errore eliminazione: " + result.d);
                        }
                    })
                    .catch(err => alert("Errore comunicazione: " + err));
            } else {
                // solo in frontend (lista non ancora salvata)
                listElem.remove();
            }
        }


        function addRow(listId) {
            const row = document.createElement('div');
            row.className = 'priority-row';
            document.getElementById(listId).appendChild(row);

            new Sortable(row, {
                group: 'shared',
                animation: 150,
                sort: true,
                onAdd: evt => {
                    const clone = evt.item.cloneNode(true);
                    evt.item.remove();
                    clone.querySelectorAll('.delete-btn').forEach(btn => btn.remove());

                    const delBtn = document.createElement('span');
                    delBtn.textContent = 'X';
                    delBtn.className = 'delete-btn';
                    delBtn.onclick = () => {
                        line.remove();
                        updateRow(row);
                    };
                    clone.appendChild(delBtn);

                    const line = document.createElement('div');
                    line.className = 'row-line';
                    line.appendChild(clone);
                    row.appendChild(line);

                    updateRow(row);
                },
                onUpdate: () => updateRow(row),
                onRemove: () => updateRow(row)
            });
        }

        function updateRow(row) {
            const lines = row.querySelectorAll('.row-line');
            lines.forEach((line, index) => {
                const existingSelect = line.querySelector('.connector-select');
                let oldValue = existingSelect?.value ?? 'AND'; // salva valore attuale

                if (existingSelect) existingSelect.remove();

                if (index < lines.length - 1) {
                    const connector = document.createElement('select');
                    connector.className = 'connector-select';
                    connector.innerHTML = `
                <option value="AND">AND</option>
                <option value="OR">OR</option>
            `;
                    connector.value = oldValue; // ripristina valore precedente
                    line.appendChild(connector);
                }
            });
        }

        new Sortable(document.getElementById('allItems'), {
            group: {
                name: 'shared',
                pull: 'clone',
                put: false
            },
            animation: 150,
            sort: false
        });

        function saveSingleList(button) {
            const listContainer = button.closest('.priority-list');
            const title = listContainer.querySelector('.editable-title')?.textContent.trim() || "Senza nome";
            const rows = listContainer.querySelectorAll('.priority-row');

            const listIdAttr = listContainer.getAttribute('data-listid');
            const listId = listIdAttr ? parseInt(listIdAttr) : null;

            const listData = {
                ListId: listId,
                ListName: title,
                Rows: []
            };

            rows.forEach((row, rowIndex) => {
                const rowData = {
                    Order: rowIndex + 1,
                    Corrections: []
                };
                row.querySelectorAll('.row-line').forEach((line, lineIndex) => {
                    const correction = line.querySelector('.item');
                    if (!correction) return;

                    const corrId = correction.getAttribute('data-id');
                    const connector = line.querySelector('select')?.value ?? null;

                    rowData.Corrections.push({
                        CorrectionId: parseInt(corrId),
                        Position: lineIndex + 1,
                        ConnectorToNext: connector
                    });
                });
                listData.Rows.push(rowData);
            });

            // Invio AJAX al server
            fetch('CorrectionsPriorityLists.aspx/SaveList', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ json: JSON.stringify(listData) })
            })
                .then(response => response.json())
                .then(result => {
                    if (result.d === "OK") {
                        alert("Lista salvata con successo");
                    } else {
                        alert("Errore: " + result.d);
                    }
                })
                .catch(error => {
                    alert("Errore comunicazione: " + error);
                });
        }

        window.onload = async () => {
            await loadCorrections();     // carica correzioni e aspetta
            loadSavedLists();            // poi carica le liste
        };
    </script>

</asp:Content>
