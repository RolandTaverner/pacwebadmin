module web.services.category;

import std.algorithm.iteration : map;
import std.algorithm.mutation : SwapStrategy;
import std.algorithm.sorting : sort;
import std.array;

import model.model;
import model.entities.category;
import web.api.category;

import web.services.common.exceptions;
import web.services.common.todto;

class CategoryService : CategoryAPI
{
    this(Model model)
    {
        m_model = model;
    }

    @safe override CategoryList getAll()
    {
        CategoryList response =
        {
            m_model.getCategories()
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array //.sort!( (a, b) => cmp(a.name, b.name) < 0, SwapStrategy.stable ).array  // TODO: decide to order here or at web UI?

        
        };

        return response;
    }

    @safe override CategoryList filter(in CategoryFilterDTO f)
    {
        auto filter = CategoryFilter(f.name);
        CategoryList response =
        {
            m_model.filterCategories(filter)
                .map!(c => toDTO(c))
                .array
                .sort!((a, b) => a.id < b.id, SwapStrategy.stable)
                .array
        };

        return response;
    }

    @safe override CategoryDTO create(in CategoryInputDTO c)
    {
        return remapExceptions!(delegate() {
            const CategoryInput ci = {name: c.name};
            const Category created = m_model.createCategory(ci);
            return toDTO(created);
        }, CategoryDTO);
    }

    @safe override CategoryDTO update(in long id, in CategoryInputDTO c)
    {
        return remapExceptions!(delegate() {
            const CategoryInput ci = {name: c.name};
            const Category updated = m_model.updateCategory(id, ci);
            return toDTO(updated);
        }, CategoryDTO);
    }

    @safe override CategoryDTO getById(in long id)
    {
        return remapExceptions!(delegate() {
            const Category got = m_model.categoryById(id);
            return toDTO(got);
        }, CategoryDTO);
    }

    @safe override void remove(in long id)
    {
        return remapExceptions!(delegate() {
            m_model.deleteCategory(id);
        }, void);
    }

private:
    Model m_model;
}
