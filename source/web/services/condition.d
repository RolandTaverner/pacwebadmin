module web.services.condition;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import model.model;
import model.entities.condition;

import web.api.condition;

import web.services.common.exceptions;
import web.services.common.todto;

class ConditionService : ConditionAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override ConditionList getAll()
    {
        ConditionList response = {
            m_model.getConditions()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override ConditionDTO create(in ConditionCreateDTO p)
    {
        return remapExceptions!(delegate() {
            const ConditionInput ci = {
                type: p.type, expression: p.expression, categoryId: p.categoryId
            };
            const Condition created = m_model.createCondition(ci);
            return toDTO(created);
        }, ConditionDTO);
    }

    @safe override ConditionDTO update(in long id, in ConditionUpdateDTO p)
    {
        return remapExceptions!(delegate() {
            const ConditionInput ci = {
                type: p.type, expression: p.expression, categoryId: p.categoryId
            };
            const Condition updated = m_model.updateCondition(id, ci);
            return toDTO(updated);
            }, ConditionDTO);
        }

        @safe override ConditionDTO getById(in long id)
        {
            return remapExceptions!(delegate() {
                const Condition got = m_model.conditionById(id);
                return toDTO(got);
            }, ConditionDTO);
        }

        @safe override void remove(in long id)
        {
            return remapExceptions!(delegate() {
                m_model.deleteCondition(id);
            }, void);
        }

    private:
        Model m_model;
    }
